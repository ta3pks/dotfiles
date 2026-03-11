# Sway

Wayland compositor configuration for i3-compatible tiling window management.

## Overview

[Sway](https://swaywm.org/) is a tiling window manager for Wayland, drop-in compatible with i3. This configuration provides a keyboard-driven workflow with workspace management and output configuration.

## Files

| File | Purpose |
|------|---------|
| `.config/sway/config` | Main Sway configuration |

## Dependencies

- **sway** - Wayland compositor
- **swaylock** - Screen locker
- **swayidle** - Idle management
- **waybar** or **i3status** - Status bar (optional)
- **wofi** or **rofi** - Application launcher (optional)
- **alacritty** or **foot** - Terminal emulator

## Customization

### Keybindings

Edit the `bindsym` directives in `config` to change keybindings. Common patterns:

```
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
```

### Outputs

Configure display outputs in the config:

```
output HDMI-A-1 resolution 1920x1080 position 0,0
```

### Autostart

Add applications to start automatically:

```
exec --no-startup-id fcitx5 -d
exec --no-startup-id dunst
```

## Symlink

```bash
ln -s ~/dotfiles/sway/.config/sway ~/.config/sway
```
