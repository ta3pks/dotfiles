import { Command } from 'commander';
import { readdir, readFile, stat } from 'node:fs/promises';
import { join, extname } from 'node:path';
import inquirer from 'inquirer';
import { z } from 'zod';
import { initMemoryService, storeMemory, listAllMemories, removeMemory, closeMemoryService } from '../../memory/index.js';
import { checkOllama, CLIError } from '../errors.js';
import { success, error, type OutputOptions } from '../output/format.js';
import ora from 'ora';

// Zod schema for validating memory files
const MemoryFileSchema = z.object({
  id: z.string().optional(),
  content: z.string().min(1, "Content is required"),
  tags: z.array(z.string()).optional().default([]),
  project: z.string().nullable().optional().default(null),
  createdAt: z.string().optional(),
  embeddingModel: z.string().optional()
});

export function registerImportCommand(program: Command): void {
  program
    .command('import')
    .description('Import memories from JSON files')
    .requiredOption('-i, --input <directory>', 'Input directory path')
    .option('--merge', 'Add to existing memories (default mode)', false)
    .option('--replace', 'Delete all existing memories before import', false)
    .option('--on-duplicate <action>', 'How to handle duplicates: skip, update, prompt', 'skip')
    .option('--yes', 'Skip confirmation prompt for --replace', false)
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Suppress output')
    .option('--no-color', 'Disable colored output')
    .action(importAction);
}

interface ImportOptions {
  input: string;
  merge?: boolean;
  replace?: boolean;
  onDuplicate?: 'skip' | 'update' | 'prompt';
  yes?: boolean;
  json?: boolean;
  quiet?: boolean;
  noColor?: boolean;
}

async function importAction(options: ImportOptions): Promise<void> {
  const opts: OutputOptions = {
    json: options.json,
    quiet: options.quiet,
    noColor: options.noColor
  };
  
  const spinner = opts.quiet ? null : ora('Importing memories...').start();
  
  try {
    // Validate input directory exists
    try {
      const stats = await stat(options.input);
      if (!stats.isDirectory()) {
        throw new CLIError(`Input path is not a directory: ${options.input}`);
      }
    } catch (err) {
      if (err instanceof CLIError) throw err;
      throw new CLIError(`Input directory does not exist: ${options.input}`);
    }
    
    // Validate on-duplicate option
    const validDuplicateActions = ['skip', 'update', 'prompt'];
    if (options.onDuplicate && !validDuplicateActions.includes(options.onDuplicate)) {
      throw new CLIError(`Invalid --on-duplicate value. Must be one of: ${validDuplicateActions.join(', ')}`);
    }
    
    await checkOllama();
    await initMemoryService();
    
    // Handle --replace mode
    if (options.replace) {
      spinner?.stop();
      
      if (!options.yes) {
        const existingCount = listAllMemories({ limit: 10000 }).length;
        console.log(`Warning: This will delete ALL ${existingCount} existing memories before import.`);
        
        const { confirm } = await inquirer.prompt([
          {
            type: 'confirm',
            name: 'confirm',
            message: 'Delete all existing memories and continue?',
            default: false
          }
        ]);
        
        if (!confirm) {
          console.log('Import cancelled.');
          await closeMemoryService();
          return;
        }
      }
      
      spinner?.start('Deleting existing memories...');
      const existingMemories = listAllMemories({ limit: 10000 });
      for (const memory of existingMemories) {
        await removeMemory(memory.id);
      }
      spinner?.start('Importing memories...');
    }
    
    // Build index of existing memories for duplicate detection
    const existingMemories = listAllMemories({ limit: 10000 });
    const existingByContent = new Map<string, typeof existingMemories[0]>();
    for (const m of existingMemories) {
      existingByContent.set(m.content, m);
    }
    
    // Read all JSON files from input directory
    const files = await readdir(options.input);
    const jsonFiles = files.filter(f => extname(f).toLowerCase() === '.json' && f !== 'metadata.json');
    
    if (jsonFiles.length === 0) {
      spinner?.stop();
      console.log('No JSON files found in input directory.');
      await closeMemoryService();
      return;
    }
    
    const stats = {
      imported: 0,
      skipped: 0,
      updated: 0,
      failed: 0,
      errors: [] as { file: string; error: string }[]
    };
    
    // Process each JSON file
    for (const file of jsonFiles) {
      const filepath = join(options.input, file);
      
      try {
        const content = await readFile(filepath, 'utf-8');
        const data = JSON.parse(content);
        
        // Validate against schema
        const result = MemoryFileSchema.safeParse(data);
        if (!result.success) {
          stats.failed++;
          stats.errors.push({
            file,
            error: `Validation failed: ${result.error.issues.map(i => i.message).join(', ')}`
          });
          continue;
        }
        
        const memoryData = result.data;
        
        // Check for duplicates (by content)
        const existing = existingByContent.get(memoryData.content);
        
        if (existing) {
          const action = options.onDuplicate || 'skip';
          
          if (action === 'skip') {
            stats.skipped++;
            continue;
          }
          
          if (action === 'prompt') {
            spinner?.stop();
            const { choice } = await inquirer.prompt([
              {
                type: 'list',
                name: 'choice',
                message: `Duplicate found in ${file}:`,
                choices: [
                  { name: 'Skip this memory', value: 'skip' },
                  { name: 'Update existing memory', value: 'update' },
                  { name: 'Cancel import', value: 'cancel' }
                ]
              }
            ]);
            
            if (choice === 'skip') {
              stats.skipped++;
              spinner?.start('Importing memories...');
              continue;
            }
            if (choice === 'cancel') {
              console.log('Import cancelled by user.');
              await closeMemoryService();
              return;
            }
            
            spinner?.start('Importing memories...');
          }
          
          // Update existing memory (delete and re-create)
          await removeMemory(existing.id);
          await storeMemory({
            content: memoryData.content,
            tags: memoryData.tags,
            project: memoryData.project || undefined
          });
          stats.updated++;
        } else {
          // Create new memory
          await storeMemory({
            content: memoryData.content,
            tags: memoryData.tags,
            project: memoryData.project || undefined
          });
          stats.imported++;
        }
      } catch (err) {
        stats.failed++;
        stats.errors.push({
          file,
          error: err instanceof Error ? err.message : String(err)
        });
      }
    }
    
    await closeMemoryService();
    
    spinner?.stop();
    
    // Report results
    if (opts.json) {
      console.log(JSON.stringify({
        success: true,
        imported: stats.imported,
        skipped: stats.skipped,
        updated: stats.updated,
        failed: stats.failed,
        errors: stats.errors.length > 0 ? stats.errors : undefined
      }, null, 2));
    } else if (!opts.quiet) {
      console.log('\nImport Summary:');
      console.log(`  ${stats.imported} imported`);
      if (stats.skipped > 0) console.log(`  ${stats.skipped} skipped (duplicates)`);
      if (stats.updated > 0) console.log(`  ${stats.updated} updated`);
      if (stats.failed > 0) console.log(`  ${stats.failed} failed`);
      
      if (stats.errors.length > 0) {
        console.log('\nErrors:');
        for (const e of stats.errors) {
          console.log(`  - ${e.file}: ${e.error}`);
        }
      }
      
      success(`Import complete from ${options.input}`, opts);
    }
    
  } catch (err) {
    spinner?.stop();
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}
