import { Command } from 'commander';
import chalk from 'chalk';
import { isValidType, getTypeDescription, getAvailableTypes } from '../types/registry.js';

export function registerTypesCommand(program: Command): void {
  program
    .command('types [type]')
    .description('List available memory types with descriptions or get details for a specific type')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Only show type names')
    .option('--no-color', 'Disable colored output')
    .action(typesAction);
}

interface TypesOptions {
  json?: boolean;
  quiet?: boolean;
  noColor?: boolean;
}

async function typesAction(type: string | undefined, options: TypesOptions): Promise<void> {
  try {
    if (options.json) {
      const types = getAvailableTypes();
      const output = types.map(t => ({
        type: t,
        description: getTypeDescription(t)
      }));
      console.log(JSON.stringify(output, null, 2));
      return;
    }

    if (options.quiet) {
      const types = getAvailableTypes();
      types.forEach(t => console.log(t));
      return;
    }

    if (type) {
      if (!isValidType(type)) {
        console.error(chalk.red(`Invalid type: ${type}`));
        console.error(chalk.dim(`Valid types: ${getAvailableTypes().join(', ')}`));
        process.exit(1);
      }
      
      const description = getTypeDescription(type);
      console.log(chalk.bold(`\n${type}`));
      console.log(chalk.dim(description || 'No description available'));
      return;
    }

    console.log(chalk.bold('\nAvailable Memory Types:\n'));
    console.log(chalk.cyan('  note') + chalk.dim('       - Generic memory note (default)'));
    console.log(chalk.cyan('  pattern') + chalk.dim('   - Code pattern with language field'));
    console.log(chalk.cyan('  decision') + chalk.dim('  - Project decision with rationale'));
    console.log(chalk.cyan('  context') + chalk.dim('   - Conversation context with session tracking'));
    console.log(chalk.cyan('  knowledge') + chalk.dim(' - Cross-project knowledge with domain'));
    console.log(chalk.cyan('  preference') + chalk.dim('- User preference with category'));
    console.log(chalk.dim('\nUsage: memory types <type> for details'));
  } catch (err) {
    console.error(chalk.red(err instanceof Error ? err.message : String(err)));
    process.exit(1);
  }
}
