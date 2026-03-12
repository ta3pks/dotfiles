import { Command } from 'commander';
import { initMemoryService, listAllMemories, closeMemoryService } from '../../memory/index.js';
import { checkOllama } from '../errors.js';
import { formatMemoryList, error, type OutputOptions } from '../output/format.js';

export function registerListCommand(program: Command): void {
  program
    .command('list')
    .description('List all memories')
    .option('-t, --tag <tag>', 'Filter by tag')
    .option('-p, --project <project>', 'Filter by project')
    .option('-l, --limit <number>', 'Maximum results', '50')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Only output memory IDs')
    .option('--no-color', 'Disable colored output')
    .action(listAction);
}

async function listAction(options: {
  tag?: string;
  project?: string;
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
    const memories = listAllMemories({
      tag: options.tag,
      project: options.project,
      limit
    });
    
    formatMemoryList(memories, opts);
    
    await closeMemoryService();
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}
