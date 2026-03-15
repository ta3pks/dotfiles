# Phase 2: Documentation & Organization - Context

**Gathered:** 2026-03-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Help users understand, navigate, and verify the repository structure. Users can install dotfiles by following instructions, locate any tool's configuration, verify prerequisites, and understand the XDG-compliant symlink strategy. Does not include creating new configurations — only documenting existing structure.

</domain>

<decisions>
## Implementation Decisions

### README Structure
- Standard sections: Quick Start, Prerequisites, Key Components, Installation, Structure, Secrets Management, Contributing
- Quick Start: One-liner only (`git clone && ./install`) — assumes user knows what they're doing
- Per-tool READMEs live in each tool's directory (e.g., `nvim/README.md`), main README links to them
- Structure section: Directory tree with brief one-liner per top-level directory

### Installation Approach
- Interactive script with TUI/CLI menu to select what to link — no stow dependency
- Script handles symlinks based on user selections
- Prerequisites: Check and stop with clear message if missing
- Existing files at symlink destination: Prompt user per-file (overwrite/skip/backup)
- Features: `--dry-run` flag to preview changes, `--undo` to restore backups

### Doc Organization
- Per-tool READMEs in each directory, general docs in repo root
- Light template per tool: Overview, Files, Dependencies, Customization
- Cross-cutting docs: CHANGELOG.md, CLAUDE.md, ADRs, philosophy doc
- Simple ADR format: `docs/decisions/NNN-title.md` — brief context, decision, consequences

### Audience & Tone
- Primary audience: Future you — assume you'll forget everything, document thoroughly
- Tone: Technical, concise, assumes Linux familiarity, minimal hand-holding
- Assumed knowledge: Shell, symlinks, PATH, config files — explain tool-specific concepts only
- Decision documentation: Inline comments for small things, ADRs for architectural choices

### Claude's Discretion
- Exact TUI/CLI library for install script (whiptail, dialog, or custom bash)
- ADR numbering scheme
- Philosophy doc structure and content
- CHANGELOG format details

</decisions>

<specifics>
## Specific Ideas

- "Script with selections so stow itself will not be needed" — interactive menu-driven install
- Focus on "future you" as audience — you'll forget why decisions were made

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-documentation-organization*
*Context gathered: 2026-03-11*
