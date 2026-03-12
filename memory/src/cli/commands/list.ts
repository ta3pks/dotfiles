import { Command } from 'commander';
import { initMemoryService, listAllMemories, closeMemoryService } from '../../memory/index.js';
import { checkOllama } from '../errors.js';
import { formatMemoryList, error, type OutputOptions } from '../output/format.js';
import { isValidType, type MemoryType } from '../types/registry.js';

export function registerListCommand(program: Command): void {
  program
    .command('list')
    .description('List all memories')
    .option('-t, --tag <tag>', 'Filter by tag')
    .option('-p, --project <project>', 'Filter by project')
    .option('--type <type>', 'Filter by memory type (pattern, decision, context, knowledge, preference)')
    .option('-l, --limit <number>', 'Maximum results', '50')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Only output memory IDs')
    .option('--no-color', 'Disable colored output')
    .action(listAction);
}

async function listAction(options: {
  tag?: string;
  project?: string;
  type?: string;
  limit?: string;
  json?: boolean;
  quiet?: boolean;
  noColor?: boolean;
}): Promise<void> {
  const opts: OutputOptions = {
    json: options.json,
    quiet: options.quiet,
    noColor: options.noColor
  };
  
  try {
    await checkOllama();
    await initMemoryService();
    
    const limit = parseInt(options.limit || '50', 10);
    
    // Validate type if provided
    if (options.type) {
      if (!isValidType(options.type)) {
        error(`Invalid type: ${options.type}. Valid types are: pattern, decision, context, knowledge, preference, note`);
        process.exit(1);
      }
    }
    
    let memories = listAllMemories({
      tag: options.tag,
      project: options.project,
      limit
    });
    
    // Filter by type if specified
    if (options.type) {
      memories = memories.filter(m => m.tags?.includes(options.type!));
    }
    
    formatMemoryList(memories, opts);
    
    await closeMemoryService();
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}
