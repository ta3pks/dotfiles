#!/usr/bin/env bun
import { Command } from 'commander';
import chalk from 'chalk';
import { isValidType, getAvailableTypes, getTypeDescription } from '../types/registry.js';

export function registerTypesCommand(program: Command): void {
  program
    .command('types')
    .description('List available memory types with descriptions')
    .option('-l, --limit <number>', 'Maximum results', '50')
    .option('-t, --tag <tag>', 'Filter by tag')
    .option('-p, --project <project>', 'Filter by project')
    .option('--type <type>', 'Filter by memory type (pattern, decision, context, knowledge, preference, note)')
    .option('-q, --quiet', 'Quiet mode')
    .option('--json', 'Output as JSON')
    .option('--no-color', 'Disable colored output')
    .action(typesAction);
}

async function typesAction(
  content: string | undefined,
  options: {
    tag?: string;
    project?: string;
    type?: string;
    limit?: string;
    json?: boolean;
    quiet?: boolean;
    noColor?: boolean
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
    
    const limit = parseInt(options.limit || '50', 10);
    
    let memories = listAllMemories({
      tag: options.tag,
      project: options.project,
      limit
    });
    
    // Apply type filter
    if (options.type) {
        if (!isValidType(options.type)) {
          error(`Invalid type: ${options.type}. Valid types are: pattern, decision, context, knowledge, preference, note`);
          process.exit(1);
        }
    }
    
    formatMemoryList(memories, opts);
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}
