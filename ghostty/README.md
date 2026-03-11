# Ghostty

Fast, cross-platform terminal emulator with GPU acceleration.

## Overview

[Ghostty](https://ghostty.org/) is a terminal emulator focused on performance and simplicity. This configuration sets up font, theme, and key bindings.

## Files

| File | Purpose |
|------|---------|
| `.config/ghostty/config` | Main configuration |

## Dependencies

- **ghostty** - Terminal emulator

## Features

- GPU-accelerated rendering
- Fast startup
- Wayland native support
- True color support

## Customization

### Font

Configure font family and size:

```
font-family = JetBrains Mono
font-size = 12
```

### Theme

Set color theme:

```
theme = catppuccin-mocha
```

### Keybindings

Custom keybindings:

```
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard
```

## Symlink

```bash
ln -s ~/dotfiles/ghostty/.config/ghostty ~/.config/ghostty
```

## Running

```bash
ghostty
```
