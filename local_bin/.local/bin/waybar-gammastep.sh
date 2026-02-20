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
    cycle-mode)
        forced=$(cat "$STATUS_FILE" 2>/dev/null)
        killall gammastep 2>/dev/null
        if [ -z "$forced" ] || [ "$forced" = "" ]; then
            # Auto -> Force Night
            gammastep -O 3000 &
            echo "night" > "$STATUS_FILE"
        elif [ "$forced" = "night" ]; then
            # Force Night -> Force Day
            gammastep -O 6500 &
            echo "day" > "$STATUS_FILE"
        else
            # Force Day -> Auto
            rm -f "$STATUS_FILE"
            gammastep &
        fi
        sleep 1
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
        echo '{"text": "☀️", "tooltip": "FORCED DAY (6500K)\nLeft-click: off\nRight-click: → auto", "class": "forced-day"}'
    elif [ "$forced" = "night" ]; then
        echo '{"text": "🌙", "tooltip": "FORCED NIGHT (3000K)\nLeft-click: off\nRight-click: → forced day", "class": "forced-night"}'
    elif [ "$is_daytime" -eq 1 ]; then
        echo '{"text": "☀️", "tooltip": "AUTO - Day mode\nLeft-click: off\nRight-click: → forced night", "class": "day"}'
    else
        echo '{"text": "🌙", "tooltip": "AUTO - Night mode\nLeft-click: off\nRight-click: → forced night", "class": "night"}'
    fi
else
    echo '{"text": "🔆", "tooltip": "OFF\nLeft-click: enable (auto)\nRight-click: → forced night", "class": "off"}'
fi
