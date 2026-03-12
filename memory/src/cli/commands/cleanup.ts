import { Command } from 'commander';
import inquirer from 'inquirer';
import { initMemoryService, listAllMemories, removeMemory, closeMemoryService } from '../../memory/index.js';
import { CLIError, ValidationError } from '../errors.js';
import { success, error, formatDate, truncate, type OutputOptions } from '../output/format.js';
import chalk from 'chalk';

interface CleanupOptions {
  olderThan?: string;
  tag?: string;
  project?: string;
  type?: string;
  dryRun?: boolean;
  yes?: boolean;
  json?: boolean;
  quiet?: boolean;
  noColor?: boolean;
}

interface MemoryToDelete {
  id: string;
  content: string;
  tags: string[];
  project: string | null;
  createdAt: number;
}

/**
 * Parse age string to Date threshold
 * Supports: Nd (days), Nw (weeks), Nm (months), Ny (years)
 */
function parseAge(ageStr: string): Date {
  const match = ageStr.match(/^(\d+)([dwmy])$/);
  if (!match) {
    throw new ValidationError(
      `Invalid --older-than format: ${ageStr}. Use format like: 30d, 2w, 6m, 1y`
    );
  }

  const value = parseInt(match[1], 10);
  const unit = match[2];
  const now = new Date();

  switch (unit) {
    case 'd':
      now.setDate(now.getDate() - value);
      break;
    case 'w':
      now.setDate(now.getDate() - (value * 7));
      break;
    case 'm':
      now.setMonth(now.getMonth() - value);
      break;
    case 'y':
      now.setFullYear(now.getFullYear() - value);
      break;
  }

  return now;
}

/**
 * Format timestamp for display
 */
function formatTimestamp(ts: number): string {
  return formatDate(ts);
}

export function registerCleanupCommand(program: Command): void {
  program
    .command('cleanup')
    .description('Clean up old or irrelevant memories')
    .option('--older-than <age>', 'Delete memories older than age (e.g., 30d, 6m, 1y)')
    .option('--tag <tag>', 'Filter by tag')
    .option('-p, --project <project>', 'Filter by project')
    .option('--type <type>', 'Filter by memory type')
    .option('--dry-run', 'Show what would be deleted without deleting')
    .option('-y, --yes', 'Skip confirmation prompt')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Suppress output')
    .option('--no-color', 'Disable colored output')
    .action(cleanupAction);
}

async function cleanupAction(options: CleanupOptions): Promise<void> {
  const opts: OutputOptions = {
    json: options.json,
    quiet: options.quiet,
    noColor: options.noColor
  };

  try {
    // Must have at least one filter
    if (!options.olderThan && !options.tag && !options.project && !options.type) {
      throw new ValidationError(
        'At least one filter is required: --older-than, --tag, --project, or --type'
      );
    }

    // Parse age threshold if provided
    let ageThreshold: Date | null = null;
    if (options.olderThan) {
      ageThreshold = parseAge(options.olderThan);
    }

    // Initialize memory service
    await initMemoryService();

    // Get all memories
    const allMemories = listAllMemories({ limit: 10000 });

    // Apply filters
    const toDelete: MemoryToDelete[] = [];

    for (const memory of allMemories) {
      let matches = true;

      // Age filter
      if (ageThreshold) {
        const memoryDate = new Date(memory.createdAt);
        if (memoryDate >= ageThreshold) {
          matches = false;
        }
      }

      // Tag filter
      if (matches && options.tag) {
        if (!memory.tags || !memory.tags.includes(options.tag)) {
          matches = false;
        }
      }

      // Project filter
      if (matches && options.project) {
        if (memory.project !== options.project) {
          matches = false;
        }
      }

      // Type filter (stored as tag)
      if (matches && options.type) {
        if (!memory.tags || !memory.tags.includes(options.type)) {
          matches = false;
        }
      }

      if (matches) {
        toDelete.push({
          id: memory.id,
          content: memory.content,
          tags: memory.tags || [],
          project: memory.project,
          createdAt: memory.createdAt
        });
      }
    }

    // No memories to delete
    if (toDelete.length === 0) {
      if (opts.json) {
        console.log(JSON.stringify({ deleted: 0, memories: [] }, null, 2));
      } else if (!opts.quiet) {
        console.log(chalk.dim('No memories match the specified criteria.'));
      }
      await closeMemoryService();
      return;
    }

    // Dry run: show what would be deleted
    if (options.dryRun) {
      if (opts.json) {
        console.log(JSON.stringify({
          dryRun: true,
          wouldDelete: toDelete.length,
          memories: toDelete.map(m => ({
            id: m.id,
            content: truncate(m.content, 100),
            tags: m.tags,
            project: m.project,
            createdAt: formatTimestamp(m.createdAt)
          }))
        }, null, 2));
      } else {
        console.log(chalk.cyan(`Would delete ${toDelete.length} memory(ies):`));
        console.log();
        for (const memory of toDelete) {
          console.log(`  ${chalk.dim(memory.id)} ${truncate(memory.content, 60)}`);
          console.log(chalk.dim(`    Tags: ${memory.tags.join(', ') || 'none'} | Created: ${formatTimestamp(memory.createdAt)}`));
        }
        console.log();
        console.log(chalk.yellow('Run without --dry-run to actually delete these memories.'));
      }
      await closeMemoryService();
      return;
    }

    // Confirmation prompt
    if (!options.yes) {
      console.log(chalk.yellow(`About to delete ${toDelete.length} memory(ies):`));
      console.log();
      
      // Show first 5 memories as preview
      const preview = toDelete.slice(0, 5);
      for (const memory of preview) {
        console.log(`  ${chalk.dim(memory.id)} ${truncate(memory.content, 60)}`);
      }
      if (toDelete.length > 5) {
        console.log(chalk.dim(`  ... and ${toDelete.length - 5} more`));
      }
      console.log();

      const { confirm } = await inquirer.prompt([
        {
          type: 'confirm',
          name: 'confirm',
          message: `Delete ${toDelete.length} memory(ies)?`,
          default: false
        }
      ]);

      if (!confirm) {
        console.log('Cancelled.');
        await closeMemoryService();
        return;
      }
    }

    // Delete memories
    let deletedCount = 0;
    const errors: { id: string; error: string }[] = [];

    for (const memory of toDelete) {
      try {
        const deleted = await removeMemory(memory.id);
        if (deleted) {
          deletedCount++;
        }
      } catch (err) {
        errors.push({
          id: memory.id,
          error: err instanceof Error ? err.message : String(err)
        });
      }
    }

    await closeMemoryService();

    // Report results
    if (opts.json) {
      console.log(JSON.stringify({
        success: true,
        deleted: deletedCount,
        failed: errors.length,
        errors: errors.length > 0 ? errors : undefined
      }, null, 2));
    } else if (!opts.quiet) {
      success(`Deleted ${deletedCount} memory(ies)`, opts);
      if (errors.length > 0) {
        console.log(chalk.yellow(`  ${errors.length} deletion(s) failed:`));
        for (const e of errors) {
          console.log(chalk.dim(`    ${e.id}: ${e.error}`));
        }
      }
    }
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(err instanceof CLIError ? err.exitCode : 1);
  }
}
