import { Command } from 'commander';
import inquirer from 'inquirer';
import { copyFile, mkdir, readdir, stat, unlink, access, readFile } from 'node:fs/promises';
import { join, basename } from 'node:path';
import { homedir } from 'node:os';
import { closeMemoryService, isInitialized } from '../../memory/index.js';
import { CLIError, NotFoundError, ValidationError } from '../errors.js';
import { success, error, formatDate, type OutputOptions } from '../output/format.js';
import chalk from 'chalk';

const DEFAULT_BACKUP_DIR = join(homedir(), '.local', 'share', 'memory', 'backups');
const DEFAULT_MAX_BACKUPS = 10;

interface BackupInfo {
  path: string;
  name: string;
  size: number;
  createdAt: Date;
}

/**
 * Get the current database path
 */
function getDatabasePath(): string {
  // The database path is determined during initMemoryService
  // Default path is ./data/metadata.sqlite
  // Use environment variable if set, otherwise default
  return process.env.MEMORY_DATA_PATH 
    ? join(process.env.MEMORY_DATA_PATH, 'metadata.sqlite')
    : join(process.cwd(), 'data', 'metadata.sqlite');
}

/**
 * Generate a timestamped backup filename
 */
function generateBackupFilename(customName?: string): string {
  if (customName) {
    return customName.endsWith('.db') ? customName : `${customName}.db`;
  }
  const now = new Date();
  const timestamp = now.toISOString()
    .replace(/:/g, '-')
    .replace(/\..+/, '');
  return `memory-backup-${timestamp}.db`;
}

/**
 * List existing backups in a directory
 * @param backupDir - Directory to search for backups
 * @param pattern - Optional prefix pattern to match. 
 *                  Undefined = default 'memory-backup-'
 *                  Empty string '' = match all .db files
 */
async function listBackups(backupDir: string, pattern?: string): Promise<BackupInfo[]> {
  try {
    await access(backupDir);
  } catch {
    return [];
  }

  const files = await readdir(backupDir);
  const backups: BackupInfo[] = [];
  const prefix = pattern === undefined ? 'memory-backup-' : pattern;

  for (const file of files) {
    if (file.endsWith('.db') && (prefix === '' || file.startsWith(prefix))) {
      const filePath = join(backupDir, file);
      const stats = await stat(filePath);
      backups.push({
        path: filePath,
        name: file,
        size: stats.size,
        createdAt: stats.mtime
      });
    }
  }

  // Sort by creation date, newest first; use filename as tiebreaker for stability
  return backups.sort((a, b) => {
    const timeDiff = b.createdAt.getTime() - a.createdAt.getTime();
    if (timeDiff !== 0) return timeDiff;
    // Descending filename sort for stability (higher numbers = more recent)
    return b.name.localeCompare(a.name);
  });
}

/**
 * Rotate old backups, keeping only maxBackups most recent
 * @param backupDir - Directory containing backups
 * @param maxBackups - Maximum number of backups to keep
 * @param pattern - Optional prefix pattern to match (default: 'memory-backup-')
 */
async function rotateBackups(backupDir: string, maxBackups: number, pattern?: string): Promise<string[]> {
  const backups = await listBackups(backupDir, pattern);
  const deleted: string[] = [];

  if (backups.length > maxBackups) {
    // Delete oldest backups beyond the limit
    const toDelete = backups.slice(maxBackups);
    for (const backup of toDelete) {
      await unlink(backup.path);
      deleted.push(backup.name);
    }
  }

  return deleted;
}

/**
 * Validate that a file is a valid SQLite database
 */
async function validateSQLiteFile(filePath: string): Promise<boolean> {
  try {
    const buffer = await readFile(filePath, { start: 0, end: 15 });
    // SQLite files start with "SQLite format 3\0"
    const header = buffer.toString('utf8', 0, 16);
    return header.startsWith('SQLite format 3');
  } catch {
    return false;
  }
}

/**
 * Format bytes to human readable size
 */
function formatSize(bytes: number): string {
  const units = ['B', 'KB', 'MB', 'GB'];
  let size = bytes;
  let unitIndex = 0;
  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }
  return `${size.toFixed(1)} ${units[unitIndex]}`;
}

export function registerBackupCommand(program: Command): void {
  const backupCmd = program
    .command('backup')
    .description('Create a backup of the memory database')
    .option('-o, --output <directory>', 'Backup directory', DEFAULT_BACKUP_DIR)
    .option('-m, --max-backups <number>', 'Maximum backups to keep', String(DEFAULT_MAX_BACKUPS))
    .option('-n, --name <name>', 'Custom backup name (overrides timestamp)')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Suppress output')
    .option('--no-color', 'Disable colored output')
    .action(backupAction);

  // Restore as subcommand
  backupCmd
    .command('restore')
    .description('Restore database from a backup file')
    .option('-f, --file <path>', 'Backup file path')
    .option('-d, --dir <directory>', 'Backup directory (for listing)', DEFAULT_BACKUP_DIR)
    .option('-l, --list', 'List available backups')
    .option('-y, --yes', 'Skip confirmation prompt')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Suppress output')
    .option('--no-color', 'Disable colored output')
    .action(restoreAction);
}

async function backupAction(
  options: {
    output?: string;
    maxBackups?: string;
    name?: string;
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
    const dbPath = getDatabasePath();
    const backupDir = options.output || DEFAULT_BACKUP_DIR;
    const maxBackups = parseInt(options.maxBackups || String(DEFAULT_MAX_BACKUPS), 10);
    
    // Check if database exists
    try {
      await access(dbPath);
    } catch {
      throw new NotFoundError(`Database file not found: ${dbPath}`);
    }
    
    // Create backup directory if needed
    await mkdir(backupDir, { recursive: true });
    
    // Generate backup filename and path
    const backupFilename = generateBackupFilename(options.name);
    const backupPath = join(backupDir, backupFilename);
    
    // Copy database file
    await copyFile(dbPath, backupPath);
    
    // Get backup size
    const stats = await stat(backupPath);
    
    // Rotate old backups - match all .db files when custom name provided
    const rotationPattern = options.name ? '' : undefined;
    const deletedBackups = await rotateBackups(backupDir, maxBackups, rotationPattern);
    
    // Report results
    if (opts.json) {
      console.log(JSON.stringify({
        success: true,
        backup: {
          path: backupPath,
          name: backupFilename,
          size: stats.size
        },
        rotated: deletedBackups
      }, null, 2));
    } else if (!opts.quiet) {
      success(`Backup created: ${backupPath}`, opts);
      console.log(chalk.dim(`  Size: ${formatSize(stats.size)}`));
      if (deletedBackups.length > 0) {
        console.log(chalk.dim(`  Rotated ${deletedBackups.length} old backup(s): ${deletedBackups.join(', ')}`));
      }
    }
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(err instanceof CLIError ? err.exitCode : 1);
  }
}

async function restoreAction(
  options: {
    file?: string;
    dir?: string;
    list?: boolean;
    yes?: boolean;
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
    const backupDir = options.dir || DEFAULT_BACKUP_DIR;
    
    // Handle --list option
    if (options.list) {
      const backups = await listBackups(backupDir);
      
      if (backups.length === 0) {
        if (opts.json) {
          console.log(JSON.stringify({ backups: [] }, null, 2));
        } else {
          console.log(chalk.dim('No backups found.'));
        }
        return;
      }
      
      if (opts.json) {
        console.log(JSON.stringify({
          backups: backups.map(b => ({
            name: b.name,
            path: b.path,
            size: b.size,
            createdAt: b.createdAt.toISOString()
          }))
        }, null, 2));
      } else {
        console.log(chalk.cyan('Available backups:'));
        console.log();
        for (const backup of backups) {
          console.log(`  ${chalk.dim(formatDate(backup.createdAt.getTime()))}  ${chalk.green(backup.name)}  ${chalk.dim(formatSize(backup.size))}`);
        }
        console.log();
        console.log(chalk.dim(`${backups.length} backup(s)`));
      }
      return;
    }
    
    // Require --file for restore
    if (!options.file) {
      throw new ValidationError('Backup file path required. Use --file <path>');
    }
    
    // Validate backup file exists
    try {
      await access(options.file);
    } catch {
      throw new NotFoundError(`Backup file not found: ${options.file}`);
    }
    
    // Validate it's a SQLite file
    const isValid = await validateSQLiteFile(options.file);
    if (!isValid) {
      throw new ValidationError('Invalid backup file: not a valid SQLite database');
    }
    
    // Get current database path
    const dbPath = getDatabasePath();
    
    // Confirmation prompt
    if (!options.yes) {
      console.log(`About to restore database from: ${options.file}`);
      console.log(`Target database: ${dbPath}`);
      console.log(chalk.yellow('This will overwrite your current database!'));
      console.log();
      
      const { confirm } = await inquirer.prompt([
        {
          type: 'confirm',
          name: 'confirm',
          message: 'Create a safety backup and proceed with restore?',
          default: false
        }
      ]);
      
      if (!confirm) {
        console.log('Cancelled.');
        return;
      }
    }
    
    // Create safety backup of current database
    let safetyBackupPath: string | null = null;
    try {
      await access(dbPath);
      const safetyName = `safety-backup-${Date.now()}.db`;
      safetyBackupPath = join(backupDir, safetyName);
      await mkdir(backupDir, { recursive: true });
      await copyFile(dbPath, safetyBackupPath);
    } catch {
      // Database doesn't exist yet, no safety backup needed
    }
    
    // Close any open connections
    if (isInitialized()) {
      await closeMemoryService();
    }
    
    // Restore: copy backup to database location
    await copyFile(options.file, dbPath);
    
    // Clean up WAL files to ensure clean restore
    const walPath = dbPath + '-wal';
    const shmPath = dbPath + '-shm';
    try { await unlink(walPath); } catch { /* ignore if doesn't exist */ }
    try { await unlink(shmPath); } catch { /* ignore if doesn't exist */ }
    
    // Report results
    if (opts.json) {
      console.log(JSON.stringify({
        success: true,
        restoredFrom: options.file,
        targetPath: dbPath,
        safetyBackup: safetyBackupPath
      }, null, 2));
    } else if (!opts.quiet) {
      success(`Database restored from: ${options.file}`, opts);
      console.log(chalk.dim(`  Target: ${dbPath}`));
      if (safetyBackupPath) {
        console.log(chalk.dim(`  Safety backup: ${safetyBackupPath}`));
      }
    }
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(err instanceof CLIError ? err.exitCode : 1);
  }
}
