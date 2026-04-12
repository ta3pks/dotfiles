# OrcaSlicer Profiles - FlashForge Adventurer 5M Pro (0.6mm nozzle)

Custom profiles with 150% speed baked in so the printer touchscreen can stay at 100%.

## Profiles

| File | Layer Height | Use Case |
|---|---|---|
| `0.18mm Fine - Copy` | 0.18mm | Detail prints, visible surfaces |
| `0.30mm Draft - Copy` | 0.30mm | Balanced speed/quality |
| `0.42mm Draft - Copy` | 0.42mm | Fast drafts, functional parts |

## Speed caps applied

Based on AD5M Pro hardware limits (300mm/s max print, 600mm/s travel, 20k mm/s^2 accel):

- Outer wall: capped at 300mm/s (visible surface quality)
- Inner wall: capped at 400mm/s (hidden, input shaping limit)
- Infill: capped at 400mm/s
- Top surface: 300mm/s
- Travel: 600mm/s

## Installation

Copy to OrcaSlicer user profiles:

```bash
# Flatpak (com.orcaslicer.OrcaSlicer)
cp process/*.json ~/.var/app/com.orcaslicer.OrcaSlicer/config/OrcaSlicer/user/default/process/
cp machine/*.json ~/.var/app/com.orcaslicer.OrcaSlicer/config/OrcaSlicer/user/default/machine/
```

Restart OrcaSlicer after copying.
