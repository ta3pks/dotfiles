import { Command } from 'commander';
import inquirer from 'inquirer';
import { initMemoryService, storeMemory, closeMemoryService } from '../../memory/index.js';
import { checkOllama, CLIError } from '../errors.js';
import { success, error, type OutputOptions } from '../output/format.js';
import {
  isValidType,
  validateInput,
  getDefaultTags,
  getDefaultProject,
  getInteractivePrompts,
  type MemoryType,
  type TypedMemoryInput
} from '../types/registry.js';

export function registerStoreCommand(program: Command): void {
  program
    .command('store [content]')
    .description('Store a new memory')
    .option('-t, --tag <tags...>', 'Tags for the memory')
    .option('-p, --project <project>', 'Project name')
    .option('--type <type>', 'Memory type (pattern, decision, context, knowledge, preference, note)')
    .option('--language <language>', 'Programming language (for pattern type)')
    .option('--rationale <text>', 'Rationale for the decision (for decision type)')
    .option('--session-id <id>', 'Session identifier (for context type)')
    .option('--domain <domain>', 'Knowledge domain (for knowledge type)')
    .option('--category <category>', 'Preference category (for preference type)')
    .option('--editor', 'Open editor for content input')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Only output memory ID')
    .option('--no-color', 'Disable colored output')
    .action(storeAction);
}

interface StoreOptions {
  tag?: string[];
  project?: string;
  type?: string;
  language?: string;
  rationale?: string;
  sessionId?: string;
  domain?: string;
  category?: string;
  editor?: boolean;
  json?: boolean;
  quiet?: boolean;
  noColor?: boolean;
}

async function storeAction(
  content: string | undefined,
  options: StoreOptions
): Promise<void> {
  const opts: OutputOptions = {
    json: options.json,
    quiet: options.quiet,
    noColor: options.noColor
  };
  
  try {
    await checkOllama();
    
    // Validate type if provided
    let memoryType: MemoryType = 'note';
    if (options.type) {
      if (!isValidType(options.type)) {
        throw new CLIError(`Invalid type: ${options.type}. Valid types are: pattern, decision, context, knowledge, preference, note`);
      }
      memoryType = options.type as MemoryType;
    }
    
    let finalContent = content;
    
    // Interactive prompts for content if not provided
    if (options.editor || !finalContent) {
      const contentAnswers = await inquirer.prompt([
        {
          type: 'editor',
          name: 'content',
          message: 'Enter memory content:',
          when: !finalContent
        }
      ]);
      finalContent = finalContent || contentAnswers.content;
    }
    
    if (!finalContent?.trim()) {
      throw new CLIError('Content is required');
    }
    
    // Build typed input
    const typedInput: Partial<TypedMemoryInput> = {
      content: finalContent.trim(),
      tags: options.tag || [],
      project: options.project
    };
    
    // Add type-specific fields
    if (memoryType === 'pattern' && options.language) {
      (typedInput as any).language = options.language;
    }
    if (memoryType === 'decision' && options.rationale) {
      (typedInput as any).rationale = options.rationale;
    }
    if (memoryType === 'context' && options.sessionId) {
      (typedInput as any).sessionId = options.sessionId;
    }
    if (memoryType === 'knowledge' && options.domain) {
      (typedInput as any).domain = options.domain;
    }
    if (memoryType === 'preference' && options.category) {
      (typedInput as any).category = options.category;
    }
    
    // Interactive prompts for type-specific fields
    if (memoryType !== 'note') {
      const typePrompts = getInteractivePrompts(memoryType);
      const neededPrompts = typePrompts.filter(p => {
        const key = p.name as keyof StoreOptions;
        return !options[key];
      });
      
      if (neededPrompts.length > 0) {
        const typeAnswers = await inquirer.prompt(neededPrompts);
        Object.assign(typedInput, typeAnswers);
      }
    }
    
    // Validate input for the type
    validateInput(memoryType, typedInput);
    
    await initMemoryService();
    
    // Get type-specific defaults
    const defaultTags = getDefaultTags(memoryType, typedInput as TypedMemoryInput);
    const defaultProject = getDefaultProject(memoryType);
    
    // Merge tags: type defaults + user tags
    const tags = [...defaultTags];
    for (const tag of (typedInput.tags || [])) {
      if (!tags.includes(tag)) {
        tags.push(tag);
      }
    }
    
    // Use type-specific project default if not provided
    const project = typedInput.project || defaultProject;
    
    const id = await storeMemory({
      content: finalContent.trim(),
      tags,
      project
    });
    
    success(`Memory stored: ${id}`, opts);
    
    if (opts.json) {
      console.log(JSON.stringify({
        id,
        type: memoryType,
        content: finalContent,
        tags,
        project
      }, null, 2));
    } else if (opts.quiet) {
      console.log(id);
    }
    
    await closeMemoryService();
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}
