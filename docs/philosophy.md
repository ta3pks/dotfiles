# Dotfiles Philosophy

## Core Principles

### 1. Explicit over Implicit

Manual symlinks over GNU Stow. Explicit `ln -s` commands over magic. 
I want to know exactly what's happening to my system.

### 2. XDG Compliance

Configuration follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/):
- Configs live in `~/.config/<tool>/`
- Data lives in `~/.local/share/<tool>/`
- Cache lives in `~/.cache/<tool>/`

This keeps the home directory clean and makes backups easier.

### 3. Documentation for Future Me

I assume I'll forget everything. Every non-obvious decision is documented:
- Inline comments for small things
- ADRs for architectural choices
- Per-tool READMEs for configuration details

### 4. No Secrets in Version Control

API keys, tokens, and credentials never enter this repository:
- Use `.env` files (gitignored)
- Use a password manager
- Pre-commit hooks scan for secrets

### 5. Tool Selection Criteria

Tools are chosen based on:
- Active maintenance
- Community adoption
- Configuration flexibility
- CLI-first (GUI configs defeat the purpose)

### 6. Minimal Dependencies

The install script should work with standard Unix tools. Optional enhancements (gum for TUI) gracefully degrade.

## Organization

```
~/dotfiles/
├── <tool>/           # One directory per tool
│   ├── .config/      # XDG config (symlinked to ~/.config/<tool>/)
│   └── README.md     # Tool-specific documentation
├── docs/             # Cross-cutting documentation
│   └── decisions/    # Architecture Decision Records
└── README.md         # Main entry point
```

## Why Not Stow?

See [ADR-001: Manual Symlinks over GNU Stow](decisions/001-manual-symlinks.md).
