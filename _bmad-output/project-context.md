---
project_name: dotfiles
user_name: Nikos
date: 2026-03-15
sections_completed: [technology_stack, language_rules, testing_rules, workflow_rules, critical_rules]
existing_patterns_found: 7
---

# Project Context for AI Agents

_Critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might miss._

---

## Technology Stack & Versions

**Primary Languages:**
- **TypeScript/Bun** - Memory system (`memory/`) - Bun runtime, NOT Node.js
- **Lua** - Neovim configuration (`nvim/.config/nvim/`)
- **Shell (Bash/Zsh)** - Scripts, bootstrap, services

**Secondary Languages:**
- Rust - Custom build directory: `$HOME/.rust_build`
- Python - MCP servers (via uvx)

**Runtime & Package Managers:**
- **Bun** - PRIMARY for all Node.js operations (NEVER use npm)
- Cargo - Rust
- uv - Python (for Serena MCP)
- Nix - System packages

**Memory System (v2.0):**
- @lancedb/lancedb ^0.26.2 - Vector storage
- SQLite - Metadata storage
- Ollama - Local embeddings (nomic-embed-text, mxbai-embed-large)
- Hono ^4.0.0 - HTTP API
- Commander ^14.0.3 - CLI framework
- Zod ^3.22.0 - Schema validation

**Key Configurations:**
- StyLua - Lua formatting (2-space indent, 120 column width)
- rustfmt - Rust formatting (unstable features enabled)
- Bun test - Test framework (NOT Jest)

---

## Critical Implementation Rules

### Package Management

```
ALWAYS use bun, NEVER npm:
- bun install    (NOT npm install)
- bun run        (NOT npm run)
- bun add        (NOT npm install <package>)
- bun test       (NOT npm test)
```

### TypeScript/Bun Rules

**Imports:**
- Use `.js` extension in imports for ESM: `import { foo } from './bar.js'`
- Use `node:` prefix for Node builtins: `import { readFile } from 'node:fs/promises'`

**File Structure:**
- CLI commands: `src/cli/commands/*.ts` with `register*Command(program)` pattern
- Services: `src/core/service.ts` with MemoryService class
- Tests: `tests/**/*.test.ts` mirroring src structure

**Error Handling:**
- Use `CLIError` class for user-facing errors in CLI
- Always include actionable error messages

### Shell Script Rules

**Naming:**
- Files: lowercase with underscores (`touch-gesture-service.sh`)
- Functions: lowercase with underscores (`start_monitor`)
- Constants: UPPERCASE (`SCRIPT_DIR`, `PID_FILE`)
- Private functions: double underscore prefix (`__DEVICE`)

**Structure:**
```bash
#!/bin/bash
# 1. Constants (UPPERCASE)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Functions
start_monitor() { ... }

# 3. Main logic
case "$1" in
    start) start_monitor ;;
    *) echo "Usage: $0 {start|stop|restart|status}"; exit 1 ;;
esac
```

**Error Handling:**
- Exit codes: 0 for success, 1 for error
- Lock files for process management
- Log to stderr: `echo "Error: ..." >&2`

### Lua/Neovim Rules

**Imports:**
```lua
-- Shorthand imports first
local ls = require("luasnip")
local s = ls.s

-- Then external requires
require("lazy").setup(...)
```

**Formatting:**
- 2-space indentation
- 120 column width (StyLua config)

### Testing Rules

**Bun Test Patterns:**
```typescript
import { describe, test, expect, beforeEach, afterEach } from 'bun:test';

describe('Feature', () => {
  let testDb: Awaited<ReturnType<typeof setupTestDb>>;

  beforeEach(async () => {
    testDb = await setupTestDb();
  });

  afterEach(async () => {
    await testDb.cleanup();
  });

  test('does something', async () => {
    const result = await testDb.service.store('content', {});
    expect(result.id).toBeDefined();
  });
});
```

**Test Helpers:**
- Use `tests/cli/helpers/setup.ts` for CLI tests
- Isolated test databases with cleanup
- `createTestMemories(service, count, options)` for fixtures

### Container & Runtime Rules

**Podman over Docker:**
- Use `podman` commands instead of `docker`
- Example: `redis-cli` wrapper uses podman with `--network host`

### MCP Integration Rules

**Available MCP Servers:**
- `serena` - Code analysis (PREFERRED for code operations)
- `zai-vision` - Image analysis (OCR, UI analysis)
- `zwebsearch`/`zwebreader` - Web access (PREFERRED over websearch)
- `zread` - GitHub documentation
- `clickhouse` - Database queries
- `nvim` - Neovim integration

**Code Operations:**
- Use Serena tools for code searches (NOT glob/grep)
- Use `serena_find_symbol`, `serena_search_for_pattern`, `serena_list_dir`

---

## Architecture Patterns

### Directory Structure

```
dotfiles/
├── memory/           # Memory system (TypeScript/Bun)
│   ├── src/
│   │   ├── cli/      # CLI commands
│   │   ├── core/     # MemoryService
│   │   ├── mcp/      # MCP server
│   │   ├── stdio/    # Stdio interface
│   │   └── http/     # HTTP API
│   └── tests/        # Test files
├── nvim/             # Neovim config (Lua)
├── zsh/              # Shell config
├── sway/             # Window manager
├── opencode/         # AI tool config
└── _bmad/            # BMAD framework
```

### Symlink Convention

- XDG paths: `tool/.config/tool/` → `~/.config/tool/`
- Manual symlinks (NO GNU stow)
- Tracked in `prerequisites.json`

---

## Critical Don't-Miss Rules

### NEVER Do

- ❌ Use `npm` commands (use `bun`)
- ❌ Use `docker` commands (use `podman`)
- ❌ Use `glob`/`grep` for code searches (use Serena)
- ❌ Use `websearch` tool (use `zwebsearch`/`zwebreader`)
- ❌ Hardcode paths (use XDG conventions)
- ❌ Commit secrets (use `.env` pattern)

### ALWAYS Do

- ✅ Use `.js` extension in TypeScript imports
- ✅ Use `node:` prefix for Node builtins
- ✅ Create isolated test databases with cleanup
- ✅ Use `CLIError` for user-facing CLI errors
- ✅ Run tests after implementation: `bun test`

### Memory System Specific

- Auto-embedding on store (no manual embedding calls)
- LanceDB for vectors, SQLite for metadata
- Ollama for local embeddings (no external API)
- Multiple interfaces: CLI, MCP, stdio, HTTP

---

## Development Commands

```bash
# Memory system
bun test                    # Run all tests
bun run cli --help          # CLI help
bun run mcp                 # Start MCP server
bun run http                # Start HTTP API

# Rust
cargo build --target-dir $HOME/.rust_build
~/.local/bin/remote_test.sh  # Remote testing

# Neovim
:Lazy                       # Plugin management
```

---

*Generated: 2026-03-15*
*Based on: GSD v2.0 completion, codebase analysis*
