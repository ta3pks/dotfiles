# Phase 5: Memory CLI - Context

**Gathered:** 2026-03-12
**Status:** Ready for planning

<domain>
## Phase Boundary

CLI for storing and retrieving memories via semantic search. Users can store code patterns, project decisions, and conversation context, then retrieve them via semantic search. Success criteria from roadmap:

1. User can store code patterns and retrieve them via semantic search
2. User can store project decisions with context and rationale
3. User can store conversation context for session continuity
4. User can search memories semantically by query
5. User can browse memories by tag, project, or date
6. User can retrieve a specific memory by its ID

</domain>

<decisions>
## Implementation Decisions

### Command Structure
- Subcommand-based: `memory <command>` pattern (e.g., `memory store`, `memory search`, `memory get`)
- Global binary name: `memory` — short, memorable, obvious purpose
- Core subcommands: `store`, `search`, `get`, `list`, `delete`, `tags`, `projects`

### Output Format
- JSON for scripting (`--json` flag), formatted text for humans (default)
- Colorized output by default, `--no-color` to disable
- Verbosity: default (concise), `-v` (verbose with metadata), `-q` (quiet/errors only)
- Search results: numbered list with ID, timestamp, tags, and content preview

### Flag Design
- Both short and long flags for common options: `-t/--tag`, `-p/--project`, `-q/--query`
- Interactive prompts for required args if not provided (unless `--non-interactive`)
- `--editor` flag for long-form content (opens $EDITOR)
- `--limit N` for pagination control (default: 10)

### Interactive Behavior
- Prompt for missing required fields in `store` command (content is required)
- Editor integration for long content: `memory store --editor` or empty content triggers $EDITOR
- Confirmation prompts for destructive operations (`delete`) unless `--force`
- Search prompts for query if not provided

### Error Handling
- Exit codes: 0 (success), 1 (error), 2 (validation error), 3 (not found)
- Error format: `[ERROR] <message>` with optional `--json` structured errors
- Recovery suggestions for common errors (e.g., "Did you mean `memory search`?")
- Graceful handling of missing/embedding failures with clear error messages

### Claude's Discretion
- Exact help text formatting and examples
- Progress indicators for slow operations (embedding)
- Exact output formatting for each command
- Tab-completion script generation (bash/zsh)
- Configuration file location and format

</decisions>

<specifics>
## Specific Ideas

- Should feel like `git` or `docker` — familiar subcommand pattern
- Works well in CI/automation (exit codes, `--json`, `--non-interactive`)
- Integrates naturally with shell workflows

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-memory-cli*
*Context gathered: 2026-03-12*
