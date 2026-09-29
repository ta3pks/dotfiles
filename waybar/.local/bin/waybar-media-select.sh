#!/bin/bash
# Show rofi menu to select active media player

players=$(playerctl -l 2>/dev/null)

if [ -z "$players" ]; then
    notify-send "No media players" "No active media players found"
    exit 0
fi

# Show rofi menu
selected=$(echo "$players" | rofi -dmenu -p "Select player" -theme-str 'window {width: 400px;}')

if [ -n "$selected" ]; then
    # Save preference to temp file
    echo "$selected" > /tmp/waybar-media-player
    # Force waybar update
    pkill -RTMIN+8 waybar
fi
