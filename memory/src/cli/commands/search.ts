import { Command } from 'commander';
import inquirer from 'inquirer';
import { initMemoryService, searchMemories, closeMemoryService } from '../../memory/index.js';
import { checkOllama } from '../errors.js';
import { formatSearchResults, error, type OutputOptions } from '../output/format.js';

export function registerSearchCommand(program: Command): void {
  program
    .command('search [query]')
    .description('Search memories semantically')
    .option('-l, --limit <number>', 'Maximum results', '10')
    .option('-t, --tag <tag>', 'Filter by tag')
    .option('-p, --project <project>', 'Filter by project')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Only output memory IDs')
    .option('-v, --verbose', 'Show full content')
    .option('--no-color', 'Disable colored output')
    .action(searchAction);
}

async function searchAction(
  query: string | undefined,
  options: {
    limit?: string;
    tag?: string;
    project?: string;
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
    
    let finalQuery = query;
    
    if (!finalQuery) {
      const answers = await inquirer.prompt([
        {
          type: 'input',
          name: 'query',
          message: 'Search query:',
          validate: (input) => input.trim().length > 0 || 'Query is required'
        }
      ]);
      finalQuery = answers.query;
    }
    
    await initMemoryService();
    
    const limit = parseInt(options.limit || '10', 10);
    let results = await searchMemories(finalQuery, { limit });
    
    if (options.tag) {
      results = results.filter(r => r.tags?.includes(options.tag!));
    }
    if (options.project) {
      results = results.filter(r => r.project === options.project);
    }
    
    formatSearchResults(results, opts);
    
    await closeMemoryService();
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}
