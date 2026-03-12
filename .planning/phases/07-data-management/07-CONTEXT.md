# Phase 7: Data Management - Context

**Gathered:** 2026-03-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can manage their memory data through export, import, backup, restore, and cleanup functionality. This phase delivers CLI commands for data portability and maintenance. Search improvements and analytics are separate phases.

</domain>

<decisions>
## Implementation Decisions

### Export Format
- Structure: Individual files (each memory as separate JSON file in directory)
- Fields: All fields included; embeddings configurable via `--embeddings` flag (disabled by default to save ~90% space)
- Format: Both pretty-print and compact options via `--pretty` flag
- Metadata: Optional export metadata (date, version, count) via `--metadata` flag

### Import Behavior
- Merge mode: Both `--merge` (add to existing) and `--replace` (delete all first) options
- Duplicates: Configurable via `--on-duplicate` flag with options: skip, update, prompt
- Validation: Strict by default — verify JSON structure, required fields, types
- Errors: Continue importing on validation failure, report summary at end

### Backup Strategy
- Location: Config default (`~/.local/share/memory/backups/`) + `--output` flag override
- Naming: Timestamped format (e.g., `memory-backup-2026-03-13T10-30-00.db`)
- Rotation: Count-based automatic cleanup via `--max-backups` flag
- Incremental: Full backups only — no incremental support

### Cleanup Criteria
- Age-based: Support cleanup by age via `--older-than` flag (e.g., `--older-than 30d`)
- Selection: Multi-criteria filtering — age, tag, project, type
- Safety: Confirmation prompt by default; `--yes` flag to bypass
- Preview: Dry-run mode via `--dry-run` flag — show what would be deleted

### Claude's Discretion
- Exact timestamp format for backup filenames
- Default max-backups count value
- Error message wording and format
- Progress reporting style during export/import

</decisions>

<specifics>
## Specific Ideas

- Export structure mirrors how git stores objects — each item as a file for easy inspection
- Import should be resilient — one bad record shouldn't fail the entire import
- Cleanup should feel safe — always preview first with dry-run

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 07-data-management*
*Context gathered: 2026-03-13*
