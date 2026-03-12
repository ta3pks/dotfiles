import chalk from 'chalk';
import Table from 'cli-table3';

export interface OutputOptions {
  json?: boolean;
  quiet?: boolean;
  verbose?: boolean;
  noColor?: boolean;
}

export function truncate(str: string, maxLen: number): string {
  if (!str) return '';
  if (str.length <= maxLen) return str;
  return str.slice(0, maxLen - 3) + '...';
}

export function formatDate(timestamp: number): string {
  const date = new Date(timestamp);
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
}

export function formatMemory(memory: any, opts: OutputOptions): void {
  if (opts.json) {
    console.log(JSON.stringify(memory, null, 2));
    return;
  }
  
  if (opts.quiet) {
    console.log(memory.id);
    return;
  }
  
  console.log();
  console.log(chalk.cyan('ID:'), memory.id);
  console.log(chalk.cyan('Created:'), formatDate(memory.createdAt));
  console.log(chalk.cyan('Tags:'), memory.tags?.join(', ') || 'none');
  if (memory.project) {
    console.log(chalk.cyan('Project:'), memory.project);
  }
  if (memory.score !== undefined) {
    console.log(chalk.cyan('Score:'), memory.score.toFixed(4));
  }
  console.log();
  console.log(memory.content);
  console.log();
}

export function formatSearchResults(results: any[], opts: OutputOptions): void {
  if (opts.json) {
    console.log(JSON.stringify(results, null, 2));
    return;
  }
  
  if (opts.quiet) {
    results.forEach(r => console.log(r.id));
    return;
  }
  
  if (results.length === 0) {
    console.log(chalk.dim('No memories found.'));
    return;
  }
  
  const c = opts.noColor ? chalk : chalk;
  
  results.forEach((r, i) => {
    console.log();
    console.log(c.dim(`${i + 1}.`), c.cyan(r.id), c.dim(`(${r.score.toFixed(4)})`));
    console.log(c.dim('   Tags:'), r.tags?.join(', ') || 'none');
    if (r.project) {
      console.log(c.dim('   Project:'), r.project);
    }
    console.log('   ', truncate(r.content, 100));
  });
  console.log();
  console.log(c.dim(`${results.length} result(s)`));
}

export function formatMemoryList(memories: any[], opts: OutputOptions): void {
  if (opts.json) {
    console.log(JSON.stringify(memories, null, 2));
    return;
  }
  
  if (opts.quiet) {
    memories.forEach(m => console.log(m.id));
    return;
  }
  
  if (memories.length === 0) {
    console.log(chalk.dim('No memories found.'));
    return;
  }
  
  const c = opts.noColor ? chalk : chalk;
  
  const table = new Table({
    head: ['ID', 'Tags', 'Project', 'Created', 'Preview'],
    style: {
      head: ['cyan'],
      border: ['dim']
    },
    colWidths: [14, 20, 12, 16, 40]
  });
  
  for (const m of memories) {
    table.push([
      m.id.slice(0, 12),
      truncate(m.tags?.join(', ') || '-', 18),
      truncate(m.project || '-', 10),
      formatDate(m.createdAt).split(',')[0],
      truncate(m.content, 38)
    ]);
  }
  
  console.log(table.toString());
  console.log(c.dim(`${memories.length} memory(ies)`));
}

export function success(message: string, opts: OutputOptions): void {
  if (opts.quiet) return;
  console.log(chalk.green('✓'), message);
}

export function error(message: string): void {
  console.error(chalk.red('[ERROR]'), message);
}
