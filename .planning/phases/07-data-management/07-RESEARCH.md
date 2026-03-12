# Phase 7: Data Management - Research

**Researched:** 2026-03-13
**Domain:** Data export/import, backup/restore, cleanup operations for SQLite + LanceDB memory system
**Confidence:** HIGH

## Summary

This phase adds data management CLI commands to the existing memory system. The system uses SQLite for metadata (`metadata.sqlite`) and LanceDB for vectors (`vectors/` directory). Export creates individual JSON files per memory (git-object style), import handles merge/replace with duplicate resolution, backup creates timestamped SQLite snapshots, and cleanup provides multi-criteria pruning with safety features.

**Primary recommendation:** Extend existing CLI pattern (Commander + inquirer + chalk) with four new commands: `export`, `import`, `backup`, and `cleanup`. Leverage existing storage layer APIs for bulk operations.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

**Export Format:**
- Structure: Individual files (each memory as separate JSON file in directory)
- Fields: All fields included; embeddings configurable via `--embeddings` flag (disabled by default to save ~90% space)
- Format: Both pretty-print and compact options via `--pretty` flag
- Metadata: Optional export metadata (date, version, count) via `--metadata` flag

**Import Behavior:**
- Merge mode: Both `--merge` (add to existing) and `--replace` (delete all first) options
- Duplicates: Configurable via `--on-duplicate` flag with options: skip, update, prompt
- Validation: Strict by default — verify JSON structure, required fields, types
- Errors: Continue importing on validation failure, report summary at end

**Backup Strategy:**
- Location: Config default (`~/.local/share/memory/backups/`) + `--output` flag override
- Naming: Timestamped format (e.g., `memory-backup-2026-03-13T10-30-00.db`)
- Rotation: Count-based automatic cleanup via `--max-backups` flag
- Incremental: Full backups only — no incremental support

**Cleanup Criteria:**
- Age-based: Support cleanup by age via `--older-than` flag (e.g., `--older-than 30d`)
- Selection: Multi-criteria filtering — age, tag, project, type
- Safety: Confirmation prompt by default; `--yes` flag to bypass
- Preview: Dry-run mode via `--dry-run` flag — show what would be deleted

### Claude's Discretion

- Exact timestamp format for backup filenames
- Default max-backups count value
- Error message wording and format
- Progress reporting style during export/import

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DATA-01 | Export/import memories (JSON format) | Individual file export pattern, validation schema with Zod, merge/replace modes |
| DATA-02 | Backup/restore functionality | SQLite file copy for backup, timestamped naming, rotation cleanup |
| DATA-03 | Memory cleanup (prune old/irrelevant) | Multi-criteria filtering via existing listMemories, batch delete via removeMemory |

</phase_requirements>

## Standard Stack

### Core (Already in Project)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| commander | ^14.0.3 | CLI argument parsing | Already used for existing CLI commands |
| inquirer | ^13.3.0 | Interactive prompts | Already used for confirmation prompts |
| chalk | ^5.6.2 | Terminal output formatting | Already used for success/error output |
| zod | ^3.22.0 | Runtime validation | Already in dependencies, use for import validation |
| nanoid | ^5.0.0 | ID generation | Already used for memory IDs |
| ora | ^9.3.0 | Progress spinners | Already in dependencies, use for export/import progress |

### Supporting (Already in Project)

| Library | Purpose | When to Use |
|---------|---------|-------------|
| fs (bun:sqlite native) | File operations | Export directory creation, backup file copy |
| path | Path manipulation | Cross-platform path handling |

### New Dependencies Required

None — all required libraries already in package.json.

## Architecture Patterns

### Existing Project Structure

```
memory/src/
├── cli/
│   ├── commands/          # Command implementations
│   │   ├── store.ts       # Pattern to follow
│   │   ├── list.ts
│   │   ├── get.ts
│   │   ├── delete.ts
│   │   └── search.ts
│   ├── types/             # Memory type definitions
│   ├── output/            # Formatting helpers
│   ├── index.ts           # Command registration
│   └── errors.ts          # CLIError class
├── storage/
│   ├── sqlite.ts          # Metadata storage API
│   ├── lancedb.ts         # Vector storage API
│   └── types.ts           # MemoryEntry interface
├── memory/
│   └── index.ts           # High-level service API
└── core/
    └── service.ts         # Core service logic
```

### Pattern 1: CLI Command Registration

**What:** Each command has its own file in `commands/` with a `register*Command` function.

**When to use:** All new commands (export, import, backup, cleanup).

**Example (from store.ts):**
```typescript
import { Command } from 'commander';

export function registerExportCommand(program: Command): void {
  program
    .command('export [output-dir]')
    .description('Export memories to JSON files')
    .option('--embeddings', 'Include embedding vectors', false)
    .option('--pretty', 'Pretty-print JSON', false)
    .option('--metadata', 'Include export metadata file', false)
    .option('-q, --quiet', 'Quiet mode')
    .option('--json', 'Output as JSON')
    .action(exportAction);
}
```

### Pattern 2: Memory Service API Usage

**What:** Use high-level memory service functions for operations.

**When to use:** All data operations that interact with stored memories.

**Available APIs (from memory/index.ts):**
```typescript
// Initialization
await initMemoryService(config);

// Read operations
listAllMemories({ project, tag, limit });  // Returns MemoryEntry[]
retrieveMemory(id);                         // Returns MemoryEntry | null
searchMemories(query, { limit, model });    // Returns MemorySearchResult[]

// Write operations
storeMemory({ content, tags, project });    // Returns id: string
removeMemory(id);                           // Returns boolean

// Cleanup
closeMemoryService();
```

### Pattern 3: SQLite Direct Access for Bulk Operations

**What:** Use sqlite.ts functions directly for export/import/backup.

**When to use:** Bulk operations that don't need vector manipulation.

**Available APIs (from storage/sqlite.ts):**
```typescript
initMetaStore(dataPath);     // Initialize connection
getConnection();             // Get raw Database for custom queries
insertMemory(entry);         // Single insert
listMemories(options);       // List with filters
deleteMemory(id);            // Single delete
closeMetaStore();            // Close connection
```

### Anti-Patterns to Avoid

- **Don't bypass memory service for normal operations:** Always use memory/index.ts APIs unless doing bulk operations
- **Don't forget vector cleanup:** When deleting memories, must also delete from LanceDB (use removeMemory, not deleteMemory directly)
- **Don't hardcode paths:** Use config or XDG defaults (~/.local/share/memory/)
- **Don't skip validation on import:** Use Zod schema to validate imported JSON

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON validation | Custom type checks | Zod schema | Type safety, detailed errors |
| Progress indication | Custom spinner | ora | Already in deps, polished UX |
| Interactive prompts | Manual readline | inquirer | Already in deps, consistent UX |
| File operations | Custom fs wrappers | Bun's native fs | Simple, no extra deps |
| Timestamp formatting | Custom date string | toISOString().replace(/[:.]/g, '-') | ISO 8601 compliant, sortable |

**Key insight:** The project already has all dependencies needed. Focus on wiring existing tools together, not adding new ones.

## Common Pitfalls

### Pitfall 1: Forgetting Vector Cleanup on Delete

**What goes wrong:** Memory deleted from SQLite but vector remains in LanceDB, causing orphaned vectors.

**Why it happens:** Direct use of `deleteMemory()` instead of `removeMemory()`.

**How to avoid:** Always use `removeMemory(id)` from memory/index.ts which handles both stores.

**Warning signs:** Vector search returns results with missing metadata.

### Pitfall 2: Import Without Validation

**What goes wrong:** Malformed JSON corrupts database, causes runtime errors later.

**Why it happens:** Skipping validation for "speed" or assuming trusted source.

**How to avoid:** Always validate with Zod schema before inserting:

```typescript
const MemoryEntrySchema = z.object({
  id: z.string(),
  content: z.string(),
  tags: z.array(z.string()).default([]),
  project: z.string().nullable().default(null),
  createdAt: z.number(),
  embeddingModel: z.string()
});
```

**Warning signs:** Import succeeds but subsequent operations fail.

### Pitfall 3: Backup During Active Writes

**What goes wrong:** Backup captures inconsistent state if writes happen during copy.

**Why it happens:** SQLite file copy without locking.

**How to avoid:** 
1. Use SQLite's backup API or
2. Briefly pause writes during backup (acceptable for small DBs)

**Warning signs:** Restored backup has missing or corrupted entries.

### Pitfall 4: Cleanup Without Dry-Run Default

**What goes wrong:** Users accidentally delete wanted memories.

**Why it happens:** Running cleanup without previewing what will be deleted.

**How to avoid:** Always require explicit `--yes` flag for actual deletion, default to dry-run mode showing what would be deleted.

**Warning signs:** User complaints about lost data.

## Code Examples

### Export Command Structure

```typescript
// src/cli/commands/export.ts
import { Command } from 'commander';
import { initMemoryService, listAllMemories, closeMemoryService } from '../../memory/index.js';
import { writeFile, mkdir } from 'fs/promises';
import { join } from 'path';
import ora from 'ora';

export function registerExportCommand(program: Command): void {
  program
    .command('export [output-dir]')
    .description('Export memories to JSON files')
    .option('--embeddings', 'Include embedding vectors', false)
    .option('--pretty', 'Pretty-print JSON', false)
    .option('--metadata', 'Include export metadata file', false)
    .option('-q, --quiet', 'Quiet mode')
    .option('--json', 'Output as JSON')
    .action(exportAction);
}

async function exportAction(
  outputDir: string | undefined,
  options: ExportOptions
): Promise<void> {
  const dir = outputDir || './memory-export';
  await mkdir(dir, { recursive: true });
  
  await initMemoryService();
  const memories = listAllMemories({});
  
  const spinner = ora(`Exporting ${memories.length} memories...`).start();
  
  for (const memory of memories) {
    const filename = `${memory.id}.json`;
    const content = options.pretty 
      ? JSON.stringify(memory, null, 2)
      : JSON.stringify(memory);
    await writeFile(join(dir, filename), content);
  }
  
  spinner.succeed(`Exported ${memories.length} memories to ${dir}`);
  await closeMemoryService();
}
```

### Import Command with Validation

```typescript
// src/cli/commands/import.ts
import { z } from 'zod';

const ImportMemorySchema = z.object({
  id: z.string().optional(),  // Will be regenerated if missing
  content: z.string(),
  tags: z.array(z.string()).default([]),
  project: z.string().nullable().default(null),
  createdAt: z.number().optional(),
  embeddingModel: z.string().optional()
});

async function importAction(
  inputDir: string,
  options: ImportOptions
): Promise<void> {
  const files = await readdir(inputDir);
  const results = { imported: 0, skipped: 0, errors: [] };
  
  for (const file of files) {
    if (!file.endsWith('.json')) continue;
    
    try {
      const content = await readFile(join(inputDir, file), 'utf-8');
      const parsed = JSON.parse(content);
      const validated = ImportMemorySchema.parse(parsed);
      
      // Handle duplicates based on --on-duplicate flag
      await handleImport(validated, options);
      results.imported++;
    } catch (err) {
      results.errors.push({ file, error: err.message });
      if (!options.continueOnError) break;
    }
  }
  
  console.log(`Imported: ${results.imported}, Skipped: ${results.skipped}`);
}
```

### Backup Command

```typescript
// src/cli/commands/backup.ts
import { copyFile } from 'fs/promises';
import { homedir } from 'os';

async function backupAction(options: BackupOptions): Promise<void> {
  const backupDir = options.output || join(homedir(), '.local/share/memory/backups');
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupPath = join(backupDir, `memory-backup-${timestamp}.db`);
  
  await mkdir(backupDir, { recursive: true });
  
  // Get database path from current config
  const dbPath = getCurrentDbPath();
  await copyFile(dbPath, backupPath);
  
  // Rotate old backups if --max-backups set
  if (options.maxBackups) {
    await rotateBackups(backupDir, options.maxBackups);
  }
  
  console.log(`Backup created: ${backupPath}`);
}
```

### Cleanup Command with Dry-Run

```typescript
// src/cli/commands/cleanup.ts
import inquirer from 'inquirer';

async function cleanupAction(options: CleanupOptions): Promise<void> {
  await initMemoryService();
  
  // Build filter criteria
  const memories = listAllMemories({
    project: options.project,
    tag: options.tag
  });
  
  // Apply additional filters
  let toDelete = memories;
  
  if (options.olderThan) {
    const cutoff = parseAgeString(options.olderThan);  // "30d" -> timestamp
    toDelete = toDelete.filter(m => m.createdAt < cutoff);
  }
  
  if (options.type) {
    toDelete = toDelete.filter(m => m.tags.includes(options.type));
  }
  
  // Dry-run mode: just show what would be deleted
  if (options.dryRun || !options.yes) {
    console.log(`Would delete ${toDelete.length} memories:`);
    toDelete.slice(0, 10).forEach(m => 
      console.log(`  - ${m.id}: ${m.content.slice(0, 50)}...`)
    );
    if (toDelete.length > 10) {
      console.log(`  ... and ${toDelete.length - 10} more`);
    }
    
    if (!options.dryRun && !options.yes) {
      const { confirm } = await inquirer.prompt([{
        type: 'confirm',
        name: 'confirm',
        message: `Delete ${toDelete.length} memories?`,
        default: false
      }]);
      if (!confirm) return;
    }
  }
  
  // Actually delete
  if (!options.dryRun) {
    for (const memory of toDelete) {
      await removeMemory(memory.id);
    }
    console.log(`Deleted ${toDelete.length} memories`);
  }
  
  await closeMemoryService();
}

function parseAgeString(age: string): number {
  const match = age.match(/^(\d+)([dwm])$/);
  if (!match) throw new Error(`Invalid age format: ${age}`);
  
  const [, num, unit] = match;
  const ms = {
    d: 86400000,      // days
    w: 604800000,     // weeks
    m: 2592000000     // months (30 days)
  };
  
  return Date.now() - (parseInt(num) * ms[unit as keyof typeof ms]);
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single JSON export file | Per-memory files (git-object style) | User decision 2026-03-13 | Easier inspection, partial import |
| Embeddings always included | Optional via flag | User decision 2026-03-13 | 90% space savings when not needed |
| Delete first, ask never | Dry-run by default, explicit --yes | User decision 2026-03-13 | Prevents accidental data loss |

**Deprecated/outdated:**
- Single-file exports: Hard to inspect, all-or-nothing import
- Silent deletion: Too dangerous for irreversible operations

## Open Questions

1. **Should export include LanceDB vectors?**
   - What we know: User decided embeddings optional via `--embeddings` flag
   - What's unclear: If enabled, how to serialize LanceDB vectors (separate file? embedded?)
   - Recommendation: Start with metadata-only export, add vectors as enhancement if needed

2. **Backup: Copy SQLite only or full data directory?**
   - What we know: SQLite has metadata, LanceDB has vectors
   - What's unclear: Should backup include both stores or just SQLite?
   - Recommendation: Backup both — copy entire data directory as tar/zip for consistency

3. **Import ID handling: Preserve or regenerate?**
   - What we know: Memory IDs are nanoid(12)
   - What's unclear: Should imported memories keep original IDs or get new ones?
   - Recommendation: Regenerate by default (avoids collisions), add `--preserve-ids` flag for migrations

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | bun test |
| Config file | None — bun test auto-detects |
| Quick run command | `bun test tests/cli/` |
| Full suite command | `bun test` |
| Estimated runtime | ~5 seconds |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DATA-01 | Export memories to JSON files | unit | `bun test tests/cli/export.test.ts` | ❌ Wave 0 gap |
| DATA-01 | Import memories from JSON | unit | `bun test tests/cli/import.test.ts` | ❌ Wave 0 gap |
| DATA-01 | Import validation catches malformed JSON | unit | `bun test tests/cli/import.test.ts` | ❌ Wave 0 gap |
| DATA-02 | Create backup with timestamp | unit | `bun test tests/cli/backup.test.ts` | ❌ Wave 0 gap |
| DATA-02 | Restore from backup | unit | `bun test tests/cli/backup.test.ts` | ❌ Wave 0 gap |
| DATA-02 | Rotate old backups | unit | `bun test tests/cli/backup.test.ts` | ❌ Wave 0 gap |
| DATA-03 | Cleanup by age filter | unit | `bun test tests/cli/cleanup.test.ts` | ❌ Wave 0 gap |
| DATA-03 | Cleanup dry-run shows preview | unit | `bun test tests/cli/cleanup.test.ts` | ❌ Wave 0 gap |
| DATA-03 | Cleanup requires confirmation | integration | `bun test tests/cli/cleanup.test.ts` | ❌ Wave 0 gap |

### Nyquist Sampling Rate

- **Minimum sample interval:** After every committed task → run: `bun test tests/cli/`
- **Full suite trigger:** Before merging final task of any plan wave
- **Phase-complete gate:** Full suite green before `/gsd-verify-work` runs
- **Estimated feedback latency per task:** ~5 seconds

### Wave 0 Gaps (must be created before implementation)

- [ ] `tests/cli/export.test.ts` — covers DATA-01 export functionality
- [ ] `tests/cli/import.test.ts` — covers DATA-01 import functionality
- [ ] `tests/cli/backup.test.ts` — covers DATA-02 backup/restore
- [ ] `tests/cli/cleanup.test.ts` — covers DATA-03 cleanup operations
- [ ] `tests/cli/helpers/setup.ts` — shared test fixtures for CLI tests

## Sources

### Primary (HIGH confidence)

- Project source code (memory/src/) — examined existing patterns and APIs
- CONTEXT.md — locked user decisions
- REQUIREMENTS.md — phase requirements DATA-01, DATA-02, DATA-03

### Secondary (MEDIUM confidence)

- Commander.js documentation — CLI patterns
- Zod documentation — validation patterns

### Tertiary (LOW confidence)

None — all findings based on project source or user decisions.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — All dependencies already in project
- Architecture: HIGH — Existing patterns well-established in codebase
- Pitfalls: HIGH — Based on observed code structure and common patterns

**Research date:** 2026-03-13
**Valid until:** 30 days — stable dependencies, established patterns
