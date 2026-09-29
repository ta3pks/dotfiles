#!/bin/bash

# Check if user selected a specific player
selected_player=$(cat /tmp/waybar-media-player 2>/dev/null)

# Use selected player or default to first available
if [ -n "$selected_player" ]; then
    player_arg="-p $selected_player"
else
    player_arg=""
fi

status=$(playerctl $player_arg status 2>/dev/null)

# Show if playing or paused, hide if no player or stopped
if [ -z "$status" ] || [ "$status" = "Stopped" ]; then
    rm -f /tmp/waybar-media-player
    echo ""
    exit 0
fi

# Get current player name for display
current_player=$(playerctl $player_arg -l 2>/dev/null | head -1)
player_short=$(echo "$current_player" | cut -d. -f1)

if [ "$status" = "Playing" ]; then
    icon="▶"
elif [ "$status" = "Paused" ]; then
    icon="⏸"
else
    icon="⏹"
fi

title=$(playerctl $player_arg metadata title 2>/dev/null)
artist=$(playerctl $player_arg metadata artist 2>/dev/null)

# Format output
if [ -n "$artist" ]; then
    echo "$icon $title - $artist [$player_short]"
else
    echo "$icon $title [$player_short]"
fi
