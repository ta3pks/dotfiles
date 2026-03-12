#!/usr/bin/env bun
import { Command } from 'commander';
import chalk from 'chalk';
import { registerStoreCommand } from './commands/store.js';
import { registerSearchCommand } from './commands/search.js';
import { registerGetCommand } from './commands/get.js';
import { registerListCommand } from './commands/list.js';
import { registerDeleteCommand } from './commands/delete.js';

const program = new Command();

program
  .name('memory')
  .description('CLI for AI memory system - store and retrieve memories via semantic search')
  .version('2.0.0');

program
  .option('--json', 'Output as JSON')
  .option('-q, --quiet', 'Quiet mode')
  .option('-v, --verbose', 'Verbose output')
  .option('--no-color', 'Disable colored output');

registerStoreCommand(program);
registerSearchCommand(program);
registerGetCommand(program);
registerListCommand(program);
registerDeleteCommand(program);

program.parse();
