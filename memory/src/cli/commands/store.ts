import { Command } from 'commander';
import inquirer from 'inquirer';
import { initMemoryService, storeMemory, closeMemoryService } from '../../memory/index.js';
import { checkOllama, CLIError } from '../errors.js';
import { success, error, type OutputOptions } from '../output/format.js';

export function registerStoreCommand(program: Command): void {
  program
    .command('store [content]')
    .description('Store a new memory')
    .option('-t, --tag <tags...>', 'Tags for the memory')
    .option('-p, --project <project>', 'Project name')
    .option('--type <type>', 'Memory type (pattern, decision, context, knowledge, preference)')
    .option('--editor', 'Open editor for content input')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Only output memory ID')
    .option('--no-color', 'Disable colored output')
    .action(storeAction);
}

async function storeAction(
  content: string | undefined,
  options: {
    tag?: string[];
    project?: string;
    type?: string;
    editor?: boolean;
    json?: boolean;
    quiet?: boolean;
    noColor?: boolean;
  }
): Promise<void> {
  const opts: OutputOptions = {
    json: options.json,
    quiet: options.quiet,
    noColor: options.noColor
  };
  
  try {
    await checkOllama();
    
    let finalContent = content;
    
    if (options.editor || !finalContent) {
      const answers = await inquirer.prompt([
        {
          type: 'editor',
          name: 'content',
          message: 'Enter memory content:',
          when: !finalContent
        }
      ]);
      finalContent = finalContent || answers.content;
    }
    
    if (!finalContent?.trim()) {
      throw new CLIError('Content is required');
    }
    
    await initMemoryService();
    
    const tags = options.tag || [];
    if (options.type && !tags.includes(options.type)) {
      tags.unshift(options.type);
    }
    
    const id = await storeMemory({
      content: finalContent.trim(),
      tags,
      project: options.project
    });
    
    success(`Memory stored: ${id}`, opts);
    
    if (opts.json) {
      console.log(JSON.stringify({ id, content: finalContent, tags, project: options.project }, null, 2));
    } else if (opts.quiet) {
      console.log(id);
    }
    
    await closeMemoryService();
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}
