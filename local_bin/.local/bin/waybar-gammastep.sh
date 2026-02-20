#!/bin/bash
# Waybar gammastep module - blue light filter with manual override

STATUS_FILE="/tmp/gammastep-forced-mode"

# Handle click events
case "$1" in
    toggle)
        if pgrep -x "gammastep" > /dev/null; then
            killall gammastep
            rm -f "$STATUS_FILE"
        else
            rm -f "$STATUS_FILE"
            gammastep &
            sleep 1
        fi
        exit 0
        ;;
    force-day)
        killall gammastep 2>/dev/null
        gammastep -O 6500 &
        echo "day" > "$STATUS_FILE"
        exit 0
        ;;
    force-night)
        killall gammastep 2>/dev/null
        gammastep -O 3000 &
        echo "night" > "$STATUS_FILE"
        exit 0
        ;;
esac

# Determine current time period
hour=$(date +%H)
if [ "$hour" -ge 7 ] && [ "$hour" -lt 18 ]; then
    is_daytime=1
else
    is_daytime=0
fi

# Output status for waybar
if pgrep -x "gammastep" > /dev/null; then
    forced=$(cat "$STATUS_FILE" 2>/dev/null)
    if [ "$forced" = "day" ]; then
        echo '{"text": "☀️", "tooltip": "Night light FORCED DAY (6500K)\nLeft-click: toggle off\nRight-click: force night", "class": "forced-day"}'
    elif [ "$forced" = "night" ]; then
        echo '{"text": "🌙", "tooltip": "Night light FORCED NIGHT (3000K)\nLeft-click: toggle off\nRight-click: force day", "class": "forced-night"}'
    elif [ "$is_daytime" -eq 1 ]; then
        echo '{"text": "☀️", "tooltip": "Night light ON - Day mode (auto)\nLeft-click: toggle off\nRight-click: force night", "class": "day"}'
    else
        echo '{"text": "🌙", "tooltip": "Night light ON - Night mode (auto)\nLeft-click: toggle off\nRight-click: force day", "class": "night"}'
    fi
else
    echo '{"text": "🔆", "tooltip": "Night light OFF\nLeft-click: enable (auto)\nRight-click: force night", "class": "off"}'
fi
