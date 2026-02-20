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

# Check if it's currently day or night (rough approximation)
# Using Tbilisi coords: sunrise ~7:45, sunset ~18:15 in Feb
hour=$(date +%H)
is_daytime=0
if [ "$hour" -ge 7 ] && [ "$hour" -lt 18 ]; then
    is_daytime=1
fi

# Output status for waybar
if pgrep -x "gammastep" > /dev/null; then
    if [ "$is_daytime" -eq 1 ]; then
        echo '{"text": "☀️", "tooltip": "Night light ON (Day mode)\nClick to disable", "class": "day"}'
    else
        echo '{"text": "🌙", "tooltip": "Night light ON (Night mode)\nClick to disable", "class": "night"}'
    fi
else
    echo '{"text": "🔆", "tooltip": "Night light OFF\nClick to enable", "class": "off"}'
fi
