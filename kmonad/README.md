# Kmonad

Advanced keyboard remapping with layers, multitap, and chord support.

## Overview

[Kmonad](https://github.com/kmonad/kmonad) is a keyboard remapping tool that runs at a low level to intercept and transform keystrokes. This configuration includes:

- Workman layer (alternative keyboard layout)
- Function layer for navigation and numbers
- Tap-hold modifiers (caps as ctrl/esc, space as shift)
- Multi-tap sequences

## Files

| File | Purpose |
|------|---------|
| `.config/kmonad/config.kbd` | Main keyboard configuration |

## Dependencies

- **kmonad** - Keyboard remapper
- **uinput** kernel module - For output device creation
- Input device permissions (`/dev/input/by-id/...`)

## Layers

| Layer | Purpose |
|-------|---------|
| `default` | Base layer with tap-hold mods |
| `function` | Navigation, numbers, arrows |
| `workman` | Workman keyboard layout |

## Key Features

### Tap-Hold Modifiers

- **Caps** → Esc (tap) / Ctrl (hold)
- **Space** → Space (tap) / Shift (hold on release)
- **Return** → Return (tap) / Super (hold on release)
- **Alt** → Function layer toggle

### Multi-Tap

- **Esc** (double tap within 200ms) → Toggle Workman layer

## Customization

### Keyboard Device

Change the input device in `defcfg`:

```
(defcfg input (device-file "/dev/input/by-id/YOUR-KEYBOARD")
```

### Adding Layers

Define new layers with `deflayer` and toggle with `layer-toggle` or `layer-add`/`layer-rem`.

## Symlink

```bash
ln -s ~/dotfiles/kmonad/.config/kmonad ~/.config/kmonad
```

## Running

```bash
kmonad ~/.config/kmonad/config.kbd
```
