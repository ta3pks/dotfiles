#!/usr/bin/env bun
import { Command } from 'commander';
import chalk from 'chalk';

// Import command registrations
import { registerStoreCommand } from './commands/store.js';
import { registerListCommand } from './commands/list.js';
import { registerGetCommand } from './commands/get.js';
import { registerDeleteCommand } from './commands/delete.js';
import { registerSearchCommand } from './commands/search.js';
import { registerBackupCommand } from './commands/backup.js';
import { registerCleanupCommand } from './commands/cleanup.js';
import { registerTypesCommand } from './commands/types.js';
import { registerExportCommand } from './commands/export.js';
import { registerImportCommand } from './commands/import.js';

const program = new Command();

program
  .name('memory')
  .description('Memory service CLI - Store, search, and manage memories')
  .version('0.1.0');

// Register all commands
registerStoreCommand(program);
registerListCommand(program);
registerGetCommand(program);
registerDeleteCommand(program);
registerSearchCommand(program);
registerBackupCommand(program);
registerCleanupCommand(program);
registerTypesCommand(program);
registerExportCommand(program);
registerImportCommand(program);

// Error handling for unknown commands
program.on('command:*', () => {
  console.error(chalk.red('Error: Unknown command'));
  console.error(chalk.dim('Run `memory --help` for available commands'));
  process.exit(1);
});

// Parse arguments
program.parse();
