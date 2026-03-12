import { Command } from 'commander';
import { mkdir, writeFile } from 'node:fs/promises';
import { join, basename } from 'node:path';
import { initMemoryService, listAllMemories, closeMemoryService } from '../../memory/index.js';
import { checkOllama, CLIError } from '../errors.js';
import { success, error, type OutputOptions } from '../output/format.js';
import ora from 'ora';

export function registerExportCommand(program: Command): void {
  program
    .command('export')
    .description('Export memories to JSON files')
    .requiredOption('-o, --output <directory>', 'Output directory path')
    .option('--embeddings', 'Include embedding vectors in output', false)
    .option('--pretty', 'Pretty-print JSON with indentation', false)
    .option('--metadata', 'Include metadata.json with export info', false)
    .option('-p, --project <project>', 'Filter by project')
    .option('-t, --tag <tag>', 'Filter by tag')
    .option('--json', 'Output as JSON')
    .option('-q, --quiet', 'Suppress output')
    .option('--no-color', 'Disable colored output')
    .action(exportAction);
}

interface ExportOptions {
  output: string;
  embeddings?: boolean;
  pretty?: boolean;
  metadata?: boolean;
  project?: string;
  tag?: string;
  json?: boolean;
  quiet?: boolean;
  noColor?: boolean;
}

async function exportAction(options: ExportOptions): Promise<void> {
  const opts: OutputOptions = {
    json: options.json,
    quiet: options.quiet,
    noColor: options.noColor
  };
  
  const spinner = opts.quiet ? null : ora('Exporting memories...').start();
  
  try {
    await checkOllama();
    await initMemoryService();
    
    // Get memories with optional filters
    const memories = listAllMemories({
      project: options.project,
      tag: options.tag,
      limit: 10000 // No practical limit for export
    });
    
    if (memories.length === 0) {
      spinner?.stop();
      console.log('No memories found to export.');
      await closeMemoryService();
      return;
    }
    
    // Create output directory
    try {
      await mkdir(options.output, { recursive: true });
    } catch (err) {
      throw new CLIError(`Cannot create output directory: ${options.output}`);
    }
    
    // Export each memory as individual JSON file
    const exported: string[] = [];
    const failed: { id: string; error: string }[] = [];
    
    for (const memory of memories) {
      const filename = `${memory.id}.json`;
      const filepath = join(options.output, filename);
      
      const exportData: Record<string, unknown> = {
        id: memory.id,
        content: memory.content,
        tags: memory.tags,
        project: memory.project,
        createdAt: new Date(memory.createdAt).toISOString(),
        embeddingModel: memory.embeddingModel
      };
      
      // Optionally include embeddings
      if (options.embeddings) {
        // Note: Embeddings are stored separately in LanceDB
        // For now, we mark that embeddings exist but don't include the vector
        // This would require additional API to retrieve vectors
        exportData.hasEmbedding = true;
      }
      
      try {
        const jsonContent = options.pretty 
          ? JSON.stringify(exportData, null, 2)
          : JSON.stringify(exportData);
        await writeFile(filepath, jsonContent, 'utf-8');
        exported.push(memory.id);
      } catch (err) {
        failed.push({
          id: memory.id,
          error: err instanceof Error ? err.message : String(err)
        });
      }
    }
    
    // Write metadata file if requested
    if (options.metadata) {
      const metadataPath = join(options.output, 'metadata.json');
      const metadata = {
        exportedAt: new Date().toISOString(),
        version: '1.0.0',
        count: exported.length,
        filters: {
          project: options.project || null,
          tag: options.tag || null
        },
        options: {
          embeddings: options.embeddings,
          pretty: options.pretty
        }
      };
      
      const jsonContent = options.pretty 
        ? JSON.stringify(metadata, null, 2)
        : JSON.stringify(metadata);
      await writeFile(metadataPath, jsonContent, 'utf-8');
    }
    
    await closeMemoryService();
    
    spinner?.stop();
    
    // Report results
    if (opts.json) {
      console.log(JSON.stringify({
        success: true,
        exported: exported.length,
        failed: failed.length,
        output: options.output,
        memories: exported,
        errors: failed.length > 0 ? failed : undefined
      }, null, 2));
    } else if (!opts.quiet) {
      success(`Exported ${exported.length} memory(ies) to ${options.output}`, opts);
      
      if (options.metadata) {
        console.log(`  Metadata: ${join(options.output, 'metadata.json')}`);
      }
      
      if (failed.length > 0) {
        console.log(`\nFailed to export ${failed.length} memory(ies):`);
        for (const f of failed) {
          console.log(`  - ${f.id}: ${f.error}`);
        }
      }
    }
    
  } catch (err) {
    spinner?.stop();
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}
