#!/bin/bash
# Cycle to next media player

players=($(playerctl -l 2>/dev/null))
count=${#players[@]}

if [ $count -eq 0 ]; then
    exit 0
fi

# Get current player
current=$(cat /tmp/waybar-media-player 2>/dev/null)

# Find next player
found=0
for i in "${!players[@]}"; do
    if [ "${players[$i]}" = "$current" ]; then
        next_idx=$(( (i + 1) % count ))
        echo "${players[$next_idx]}" > /tmp/waybar-media-player
        found=1
        break
    fi
done

# If current not found, use first
if [ $found -eq 0 ]; then
    echo "${players[0]}" > /tmp/waybar-media-player
fi

# Force waybar update
pkill -RTMIN+8 waybar
