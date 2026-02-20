#!/bin/bash
# Waybar gammastep module - shows blue light filter status with toggle

STATUS_FILE="/tmp/gammastep-status"

# Handle click events
if [ "$1" = "toggle" ]; then
    if pgrep -x "gammastep" > /dev/null; then
        killall gammastep
        rm -f "$STATUS_FILE"
    else
        gammastep &
        sleep 1
    fi
    exit 0
fi

# Output status for waybar
if pgrep -x "gammastep" > /dev/null; then
    echo '{"text": "🌙", "tooltip": "Night light ON\nClick to disable", "class": "night"}'
else
    echo '{"text": "🔆", "tooltip": "Night light OFF\nClick to enable", "class": "off"}'
fi
