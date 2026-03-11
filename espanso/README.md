# Espanso

Cross-platform text expansion for abbreviations and corrections.

## Overview

[Espanso](https://espanso.org/) is a text expansion tool that replaces short triggers with longer text. This configuration includes packages for contractions and common misspelling corrections.

## Files

| File | Purpose |
|------|---------|
| `.config/espanso/config/default.yml` | Main configuration |
| `.config/espanso/match/` | Match definitions |

## Dependencies

- **espanso** - Text expansion daemon

## Configuration

### Search Trigger

The search trigger is set to `.search` for Espanso's built-in search functionality.

## Packages

Install additional packages:

```bash
espanso install <package-name>
```

Common packages:
- `contractions` - Expand don't → do not
- `misspell` - Auto-correct common typos

## Customization

### Adding Matches

Create or edit files in `.config/espanso/match/`:

```yaml
matches:
  - trigger: ":addr"
    replace: "123 Main Street, City, Country"
  - trigger: ":sig"
    replace: "Best regards,\nYour Name"
```

### Application-Specific

Limit matches to specific applications:

```yaml
matches:
  - trigger: ":code"
    replace: "```$|$```"
    word: true
```

## Symlink

```bash
ln -s ~/dotfiles/espanso/.config/espanso ~/.config/espanso
```

## Running

```bash
espanso start
espanso restart  # After config changes
```
