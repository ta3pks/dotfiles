import { Command } from 'commander';
import inquirer from 'inquirer';
import { initMemoryService, retrieveMemory, removeMemory, closeMemoryService } from '../../memory/index.js';
import { checkOllama, NotFoundError } from '../errors.js';
import { success, error, type OutputOptions } from '../output/format.js';

export function registerDeleteCommand(program: Command): void {
  program
    .command('delete <id>')
    .description('Delete a memory')
    .option('-f, --force', 'Skip confirmation')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Suppress output')
    .option('--no-color', 'Disable colored output')
    .action(deleteAction);
}

async function deleteAction(
  id: string,
  options: {
    force?: boolean;
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
    await initMemoryService();
    
    const memory = retrieveMemory(id);
    
    if (!memory) {
      throw new NotFoundError(`Memory not found: ${id}`);
    }
    
    if (!options.force) {
      console.log(`About to delete memory ${id}:`);
      console.log(`  Content: ${memory.content.slice(0, 100)}${memory.content.length > 100 ? '...' : ''}`);
      console.log();
      
      const { confirm } = await inquirer.prompt([
        {
          type: 'confirm',
          name: 'confirm',
          message: 'Delete this memory?',
          default: false
        }
      ]);
      
      if (!confirm) {
        console.log('Cancelled.');
        await closeMemoryService();
        return;
      }
    }
    
    const deleted = await removeMemory(id);
    
    if (deleted) {
      success(`Memory deleted: ${id}`, opts);
    } else {
      throw new NotFoundError(`Memory not found: ${id}`);
    }
    
    await closeMemoryService();
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(err instanceof NotFoundError ? 3 : 1);
  }
}
