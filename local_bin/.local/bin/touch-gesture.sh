#!/bin/bash

# Simple touch gesture detector for virtual keyboard toggle
# This script monitors for 3-finger touch and toggles keyboard

TOUCH_COUNT_FILE="/tmp/touch_count"
LAST_TOUCH_TIME="/tmp/last_touch_time"

# Initialize
echo "0" > "$TOUCH_COUNT_FILE"
echo "0" > "$LAST_TOUCH_TIME"

monitor_touch() {
    # Monitor libinput touch events and count fingers
    libinput debug-events --device /dev/input/event6 2>/dev/null | \
    while read -r line; do
        if [[ "$line" =~ TOUCH_DOWN ]]; then
            current_time=$(date +%s%3N)
            last_time=$(cat "$LAST_TOUCH_TIME")
            
            # Reset count if more than 500ms since last touch
            if [ $((current_time - last_time)) -gt 500 ]; then
                echo "1" > "$TOUCH_COUNT_FILE"
            else
                current_count=$(cat "$TOUCH_COUNT_FILE")
                echo $((current_count + 1)) > "$TOUCH_COUNT_FILE"
            fi
            
            echo "$current_time" > "$LAST_TOUCH_TIME"
            
            # Check if we have 3 fingers
            touch_count=$(cat "$TOUCH_COUNT_FILE")
            if [ "$touch_count" -ge 3 ]; then
                echo "3 fingers detected - toggling keyboard"
                /home/nikos/dotfiles/local_bin/.local/bin/toggle-keyboard.sh
                echo "0" > "$TOUCH_COUNT_FILE"
                sleep 1  # Prevent multiple triggers
            fi
        fi
        
        if [[ "$line" =~ TOUCH_UP ]]; then
            # Reset on touch up
            sleep 0.5
            echo "0" > "$TOUCH_COUNT_FILE"
        fi
    done
}

echo "Touch gesture monitor started. Touch with 3 fingers simultaneously to toggle keyboard."
monitor_touch