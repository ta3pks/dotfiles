import { Command } from 'commander';
import { initMemoryService, retrieveMemory, closeMemoryService } from '../../memory/index.js';
import { checkOllama, NotFoundError } from '../errors.js';
import { formatMemory, error, type OutputOptions } from '../output/format.js';

export function registerGetCommand(program: Command): void {
  program
    .command('get <id>')
    .description('Retrieve a memory by ID')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Only output content')
    .option('-v, --verbose', 'Show all metadata')
    .option('--no-color', 'Disable colored output')
    .action(getAction);
}

async function getAction(
  id: string,
  options: {
    json?: boolean;
    quiet?: boolean;
    verbose?: boolean;
    noColor?: boolean;
  }
): Promise<void> {
  const opts: OutputOptions = {
    json: options.json,
    quiet: options.quiet,
    verbose: options.verbose,
    noColor: options.noColor
  };
  
  try {
    await checkOllama();
    await initMemoryService();
    
    const memory = retrieveMemory(id);
    
    if (!memory) {
      throw new NotFoundError(`Memory not found: ${id}`);
    }
    
    formatMemory(memory, opts);
    
    await closeMemoryService();
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(err instanceof NotFoundError ? 3 : 1);
  }
}
