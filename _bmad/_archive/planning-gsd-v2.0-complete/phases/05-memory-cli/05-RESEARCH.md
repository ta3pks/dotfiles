# Phase 5: Memory CLI - Research

**Researched:** 2026-03-12
**Domain:** Command-line interface for memory operations
**Confidence:** HIGH

## Summary

Phase 5 builds a CLI tool (`memory`) that exposes the Phase 4 memory service to users. The CLI follows git/docker-style subcommand patterns with JSON output support for scripting, interactive prompts for missing args, and proper exit codes for CI/automation.

**Primary recommendation:** Use Bun's built-in CLI utilities with commander.js for argument parsing, chalk for colorized output, and inquirer for interactive prompts. The memory service from Phase 4 provides all backend operations.

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CLI-01 | Command-line tool for memory operations | Binary: `memory` with subcommands |
| CLI-02 | Store command (add memory with auto-embedding) | Uses `storeMemory()` from Phase 4 |
| CLI-03 | Search command (semantic search across memories) | Uses `searchMemories()` from Phase 4 |
| CLI-04 | Retrieve command (get memory by ID) | Uses `retrieveMemory()` from Phase 4 |
| CLI-05 | List command (browse by tag/project/date) | Uses `listAllMemories()` from Phase 4 |
| MEM-01 | System stores code patterns and retrieve via semantic search | Memory type: `pattern` with semantic search |
| MEM-02 | System stores project decisions with context and rationale | Memory type: `decision` |
| MEM-03 | System stores conversation context for session continuity | Memory type: `context` |
| MEM-04 | System stores cross-project knowledge (reusable patterns) | Memory type: `knowledge`, cross-project by default |
| MEM-05 | System stores user preferences and coding style | Memory type: `preference` |

</phase_requirements>

## Existing Infrastructure

Phase 4 provides the complete backend via `src/memory/index.ts`:

```typescript
// Already implemented:
initMemoryService(config)     // Initialize storage
storeMemory(input)            // Store with auto-embedding
searchMemories(query, opts)   // Semantic search
retrieveMemory(id)            // Get by ID
listAllMemories(opts)         // Browse by tag/project
removeMemory(id)              // Delete memory
closeMemoryService()          // Cleanup
```

**CLI builds on these primitives - no new storage logic needed.**

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| commander | 12.x | Argument parsing | Industry standard, git-like subcommands |
| chalk | 5.x | Colorized output | ESM-native, tree-shakeable |
| inquirer | 9.x | Interactive prompts | Rich prompt types, validation |
| cli-table3 | 0.6.x | Table formatting | Unicode support, customizable |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| ora | 7.x | Progress spinners | Long operations (embedding) |
| conf | 11.x | Config file storage | User preferences, defaults |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| commander | yargs | More verbose, less intuitive subcommands |
| commander | oclif | Overkill for single-binary tool |
| chalk | kleur | Smaller but less feature-complete |
| inquirer | enquirer | Lighter but less maintained |

**Installation:**
```bash
cd memory && bun add commander chalk inquirer cli-table3 ora conf
```

## Architecture Patterns

### Recommended Project Structure

```
memory/
├── src/
│   ├── cli/
│   │   ├── index.ts           # CLI entry point
│   │   ├── commands/
│   │   │   ├── store.ts       # memory store
│   │   │   ├── search.ts      # memory search
│   │   │   ├── get.ts         # memory get
│   │   │   ├── list.ts        # memory list
│   │   │   ├── delete.ts      # memory delete
│   │   │   ├── tags.ts        # memory tags
│   │   │   └── projects.ts    # memory projects
│   │   ├── output/
│   │   │   ├── formatter.ts   # Output formatting
│   │   │   ├── json.ts        # JSON output
│   │   │   └── table.ts       # Table output
│   │   └── prompts/
│   │       └── interactive.ts # Interactive prompts
│   ├── memory/                # Phase 4 (existing)
│   ├── storage/               # Phase 4 (existing)
│   └── embeddings/            # Phase 4 (existing)
├── package.json
└── tsconfig.json
```

### Pattern 1: Subcommand Structure

**What:** Git-like subcommands with commander.js

**Example:**
```typescript
import { Command } from 'commander';

const program = new Command()
  .name('memory')
  .description('CLI for AI coding memory system')
  .version('1.0.0');

program
  .command('store')
  .description('Store a new memory')
  .argument('[content]', 'Memory content')
  .option('-t, --tag <tags...>', 'Tags for the memory')
  .option('-p, --project <project>', 'Project name')
  .option('--type <type>', 'Memory type (pattern, decision, context, preference)')
  .option('--editor', 'Open editor for content')
  .action(storeCommand);

program
  .command('search')
  .description('Search memories semantically')
  .argument('[query]', 'Search query')
  .option('-l, --limit <number>', 'Max results', '10')
  .option('-t, --tag <tag>', 'Filter by tag')
  .option('-p, --project <project>', 'Filter by project')
  .option('--json', 'Output as JSON')
  .action(searchCommand);

program.parse();
```

### Pattern 2: Output Formatting

**What:** Support both human-readable and JSON output

**Example:**
```typescript
interface OutputOptions {
  json?: boolean;
  quiet?: boolean;
  verbose?: boolean;
}

function formatSearchResults(results: MemorySearchResult[], opts: OutputOptions) {
  if (opts.json) {
    console.log(JSON.stringify(results, null, 2));
    return;
  }
  
  if (opts.quiet) {
    results.forEach(r => console.log(r.id));
    return;
  }
  
  // Human-readable output
  results.forEach((r, i) => {
    console.log(chalk.dim(`${i + 1}.`), chalk.cyan(r.id));
    console.log(chalk.dim('   Tags:'), r.tags.join(', '));
    console.log(chalk.dim('   Score:'), r.score.toFixed(3));
    console.log('   ', truncate(r.content, 100));
    console.log();
  });
}
```

### Pattern 3: Interactive Prompts

**What:** Prompt for missing required fields

**Example:**
```typescript
import inquirer from 'inquirer';

async function promptForMemory(input: Partial<CreateMemoryInput>): Promise<CreateMemoryInput> {
  const questions = [];
  
  if (!input.content) {
    questions.push({
      type: 'editor',
      name: 'content',
      message: 'Enter memory content:',
    });
  }
  
  if (!input.tags?.length) {
    questions.push({
      type: 'input',
      name: 'tags',
      message: 'Tags (comma-separated):',
      filter: (val: string) => val.split(',').map(t => t.trim()).filter(Boolean),
    });
  }
  
  if (!input.project) {
    questions.push({
      type: 'input',
      name: 'project',
      message: 'Project (optional):',
    });
  }
  
  const answers = await inquirer.prompt(questions);
  return { ...input, ...answers } as CreateMemoryInput;
}
```

### Pattern 4: Exit Codes

**What:** Proper exit codes for scripting

**Example:**
```typescript
// Exit codes
const EXIT_SUCCESS = 0;
const EXIT_ERROR = 1;
const EXIT_VALIDATION_ERROR = 2;
const EXIT_NOT_FOUND = 3;

async function getCommand(id: string, opts: OutputOptions) {
  try {
    const memory = retrieveMemory(id);
    if (!memory) {
      console.error(chalk.red(`[ERROR] Memory not found: ${id}`));
      process.exit(EXIT_NOT_FOUND);
    }
    formatMemory(memory, opts);
  } catch (err) {
    console.error(chalk.red(`[ERROR] ${err.message}`));
    process.exit(EXIT_ERROR);
  }
}
```

### Pattern 5: Memory Type System

**What:** Type-specific behavior for different memory kinds

**Example:**
```typescript
type MemoryType = 'pattern' | 'decision' | 'context' | 'knowledge' | 'preference';

interface TypedMemoryInput extends CreateMemoryInput {
  type: MemoryType;
  rationale?: string;    // For decisions
  language?: string;     // For patterns
  scope?: 'local' | 'global';  // For preferences
}

const TYPE_DEFAULT_TAGS: Record<MemoryType, string[]> = {
  pattern: ['code', 'pattern'],
  decision: ['decision', 'architecture'],
  context: ['session', 'context'],
  knowledge: ['knowledge', 'reusable'],
  preference: ['preference', 'style'],
};

function applyTypeDefaults(input: TypedMemoryInput): CreateMemoryInput {
  return {
    ...input,
    tags: [...new Set([...input.tags || [], ...TYPE_DEFAULT_TAGS[input.type]])],
  };
}
```

### Anti-Patterns to Avoid

- **Duplicate storage logic:** Use Phase 4 service, don't re-implement
- **Blocking on missing Ollama:** Check health with clear error message
- **Ignoring exit codes:** Scripts depend on proper exit codes
- **Mixed output formats:** Always respect `--json` flag
- **Hardcoded paths:** Use config file or env var for data path

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Argument parsing | Custom argv parser | commander.js | Handles edge cases, help generation |
| Interactive prompts | Custom readline | inquirer | Validation, multi-select, editor |
| Colorized output | ANSI escape codes | chalk | Cross-platform, composable |
| Table formatting | Manual spacing | cli-table3 | Unicode, alignment, borders |

## Common Pitfalls

### Pitfall 1: Missing Initialization

**What goes wrong:** Commands fail because memory service not initialized.

**How to avoid:**
```typescript
// In CLI entry point
async function ensureInitialized() {
  if (!isInitialized()) {
    await initMemoryService({ dataPath: getConfigPath() });
  }
}

// Wrap all commands
program.hook('preAction', async () => {
  await ensureInitialized();
});
```

### Pitfall 2: Ollama Not Running

**What goes wrong:** Store/search fails with connection error.

**How to avoid:**
```typescript
async function checkOllama() {
  const healthy = await checkOllamaHealth();
  if (!healthy) {
    console.error(chalk.red('[ERROR] Ollama is not running.'));
    console.error(chalk.dim('Start with: systemctl --user start ollama'));
    process.exit(EXIT_ERROR);
  }
}
```

### Pitfall 3: Editor Integration Fails

**What goes wrong:** `--editor` flag fails on systems without $EDITOR.

**How to avoid:**
```typescript
function getEditor(): string {
  return process.env.EDITOR || process.env.VISUAL || 'nano';
}
```

### Pitfall 4: Long Content Truncation in Output

**What goes wrong:** Search results flood terminal with full content.

**How to avoid:**
```typescript
function truncate(str: string, maxLen: number): string {
  if (str.length <= maxLen) return str;
  return str.slice(0, maxLen - 3) + '...';
}
```

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Bun Test (built-in) |
| Quick run command | `bun test tests/cli/` |
| Estimated runtime | ~3 seconds |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command |
|--------|----------|-----------|-------------------|
| CLI-01 | CLI binary executes | integration | `bun test tests/cli/binary.test.ts` |
| CLI-02 | Store command works | integration | `bun test tests/cli/store.test.ts` |
| CLI-03 | Search command works | integration | `bun test tests/cli/search.test.ts` |
| CLI-04 | Get command works | integration | `bun test tests/cli/get.test.ts` |
| CLI-05 | List command works | integration | `bun test tests/cli/list.test.ts` |
| MEM-01 | Pattern storage works | integration | `bun test tests/cli/types/pattern.test.ts` |
| MEM-02 | Decision storage works | integration | `bun test tests/cli/types/decision.test.ts` |
| MEM-03 | Context storage works | integration | `bun test tests/cli/types/context.test.ts` |
| MEM-04 | Knowledge storage works | integration | `bun test tests/cli/types/knowledge.test.ts` |
| MEM-05 | Preference storage works | integration | `bun test tests/cli/types/preference.test.ts` |

### Wave 0 Gaps (must be created before implementation)

- [ ] `tests/cli/binary.test.ts` — CLI executes and shows help
- [ ] `tests/cli/store.test.ts` — Store command
- [ ] `tests/cli/search.test.ts` — Search command
- [ ] `tests/cli/get.test.ts` — Get command
- [ ] `tests/cli/list.test.ts` — List command
- [ ] `tests/cli/delete.test.ts` — Delete command
- [ ] `tests/cli/output.test.ts` — JSON and table formatting
- [ ] `tests/cli/types/*.test.ts` — Memory type handlers

## Sources

### Primary (HIGH confidence)

- Phase 4 implementation: `memory/src/memory/index.ts`
- CONTEXT.md from /gsd-discuss-phase
- commander.js docs: github.com/tj/commander.js
- inquirer docs: github.com/SBoudrias/Inquirer.js

### Secondary (MEDIUM confidence)

- chalk docs: github.com/chalk/chalk
- cli-table3 docs: github.com/cli-table/cli-table3
- Node.js exit codes convention

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Well-known libraries, proven patterns
- Architecture: HIGH - Building on Phase 4 service
- Pitfalls: HIGH - Common CLI development issues

**Research date:** 2026-03-12
**Valid until:** 2026-04-12 (30 days - stable libraries)
