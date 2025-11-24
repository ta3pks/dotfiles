#!/bin/bash

# Clean single-instance gesture recognition script

# Add timestamp to log for debugging
echo "$(date): Gesture recognition script started" >> /tmp/touch-gesture.log

TOUCH_COUNT_FILE="/tmp/touch_count"
TOUCH_POSITIONS_FILE="/tmp/touch_positions"
GESTURE_ACTIVE_FILE="/tmp/gesture_active"

# Initialize
echo "0" > "$TOUCH_COUNT_FILE"
echo "" > "$TOUCH_POSITIONS_FILE"
echo "false" > "$GESTURE_ACTIVE_FILE"

# Action functions
workspace_next() {
    # Get current workspace number
    current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name' | grep -o '[0-9]\+')
    if [ -z "$current" ]; then
        current=1
    fi
    
    # Go to next numbered workspace (create if doesn't exist)
    next=$((current + 1))
    if [ "$next" -gt 9 ]; then
        next=1
    fi
    swaymsg workspace number "$next"
}

workspace_prev() {
    # Get current workspace number
    current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name' | grep -o '[0-9]\+')
    if [ -z "$current" ]; then
        current=1
    fi
    
    # Go to previous numbered workspace (create if doesn't exist)
    prev=$((current - 1))
    if [ "$prev" -lt 1 ]; then
        prev=9
    fi
    swaymsg workspace number "$prev"
}

move_window_next() {
    # Get current workspace number
    current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name' | grep -o '[0-9]\+')
    if [ -z "$current" ]; then
        current=1
    fi
    
    # Move focused window to next workspace and follow it
    next=$((current + 1))
    if [ "$next" -gt 9 ]; then
        next=1
    fi
    swaymsg move container to workspace number "$next", workspace number "$next"
}

move_window_prev() {
    # Get current workspace number
    current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused==true).name' | grep -o '[0-9]\+')
    if [ -z "$current" ]; then
        current=1
    fi
    
    # Move focused window to previous workspace and follow it
    prev=$((current - 1))
    if [ "$prev" -lt 1 ]; then
        prev=9
    fi
    swaymsg move container to workspace number "$prev", workspace number "$prev"
}

launch_ulauncher() {
    ulauncher
}

toggle_keyboard() {
    /home/nikos/dotfiles/local_bin/.local/bin/toggle-keyboard.sh
}

# Extract and convert coordinates to integers
extract_coordinates() {
    local line="$1"
    # Look for pattern like "57.58/72.64 (163.58/136.36mm)"
    if [[ "$line" =~ ([0-9]+)\.([0-9]+)/([0-9]+)\.([0-9]+) ]]; then
        local x_int="${BASH_REMATCH[1]}${BASH_REMATCH[2]:0:2}"  # Take first 2 decimal places
        local y_int="${BASH_REMATCH[3]}${BASH_REMATCH[4]:0:2}"
        echo "$x_int $y_int"
    fi
}

# Simple direction detection based on first and last positions
detect_swipe_direction() {
    local positions_file="$1"
    local min_distance=300  # Minimum swipe distance
    
    if [ ! -f "$positions_file" ] || [ ! -s "$positions_file" ]; then
        echo "none"
        return
    fi
    
    # Get first and last positions
    local first_pos=$(head -1 "$positions_file")
    local last_pos=$(tail -1 "$positions_file")
    
    if [ -z "$first_pos" ] || [ -z "$last_pos" ]; then
        echo "none"
        return
    fi
    
    local first_x=$(echo "$first_pos" | cut -d' ' -f1)
    local first_y=$(echo "$first_pos" | cut -d' ' -f2)
    local last_x=$(echo "$last_pos" | cut -d' ' -f1)
    local last_y=$(echo "$last_pos" | cut -d' ' -f2)
    
    # Calculate movement (integer math)
    local delta_x=$((last_x - first_x))
    local delta_y=$((last_y - first_y))
    
    # Absolute values
    local abs_x=${delta_x#-}
    local abs_y=${delta_y#-}
    
    # Determine direction
    if [ "$abs_x" -gt "$min_distance" ] && [ "$abs_x" -gt "$abs_y" ]; then
        if [ "$delta_x" -gt 0 ]; then
            echo "right"
        else
            echo "left"
        fi
    elif [ "$abs_y" -gt "$min_distance" ] && [ "$abs_y" -gt "$abs_x" ]; then
        if [ "$delta_y" -gt 0 ]; then
            echo "down"
        else
            echo "up"
        fi
    else
        echo "none"
    fi
}

# Auto-detect touchscreen device
get_touchscreen_device() {
    libinput list-devices | grep -A 5 "Device:.*ELAN9008" | grep "Kernel:" | head -1 | awk '{print $2}'
}

monitor_touch() {
    local finger_count=0
    local gesture_active=false
    local motion_counter=0
    
    # Auto-detect touchscreen device
    local touchscreen_device=$(get_touchscreen_device)
    if [ -z "$touchscreen_device" ]; then
        echo "No touchscreen device found"
        exit 1
    fi
    
    echo "Using touchscreen device: $touchscreen_device"
    
    # Main loop with restart capability
    while true; do
        echo "Starting libinput monitor..."
        libinput debug-events --device "$touchscreen_device" 2>/dev/null | \
        while read -r line; do
        if [[ "$line" =~ TOUCH_DOWN ]]; then
            # Start new gesture if not active
            if [ "$gesture_active" = false ]; then
                echo "true" > "$GESTURE_ACTIVE_FILE"
                finger_count=0
                echo "" > "$TOUCH_POSITIONS_FILE"
                gesture_active=true
                motion_counter=0
            fi
            
            finger_count=$((finger_count + 1))
            echo "$finger_count" > "$TOUCH_COUNT_FILE"
            
            # Record initial position
            coords=$(extract_coordinates "$line")
            if [ -n "$coords" ]; then
                echo "$coords" > "$TOUCH_POSITIONS_FILE"
            fi
            
        elif [[ "$line" =~ TOUCH_MOTION ]]; then
            if [ "$gesture_active" = true ]; then
                motion_counter=$((motion_counter + 1))
                
                # Record every 3rd motion event to reduce noise
                if [ $((motion_counter % 3)) -eq 0 ]; then
                    coords=$(extract_coordinates "$line")
                    if [ -n "$coords" ]; then
                        echo "$coords" >> "$TOUCH_POSITIONS_FILE"
                    fi
                fi
            fi
            
        elif [[ "$line" =~ TOUCH_UP ]]; then
            if [ "$gesture_active" = true ]; then
                # Process completed gesture
                finger_count=$(cat "$TOUCH_COUNT_FILE")
                
                direction=$(detect_swipe_direction "$TOUCH_POSITIONS_FILE" | tail -1)
                
                if [ "$finger_count" -eq 2 ]; then
                    # 2-finger swipe for workspace navigation
                    case "$direction" in
                        "left")
                            workspace_prev
                            ;;
                        "right")
                            workspace_next
                            ;;
                    esac
                elif [ "$finger_count" -eq 3 ]; then
                    # 3-finger swipe for window movement or keyboard toggle
                    case "$direction" in
                        "left")
                            move_window_prev
                            ;;
                        "right")
                            move_window_next
                            ;;
                        "up"|"down")
                            toggle_keyboard
                            ;;
                    esac
                elif [ "$finger_count" -eq 4 ]; then
                    # 4-finger swipe for ulauncher
                    case "$direction" in
                        "up"|"down")
                            launch_ulauncher
                            ;;
                    esac
                fi
                
                # Reset for next gesture
                echo "0" > "$TOUCH_COUNT_FILE"
                echo "" > "$TOUCH_POSITIONS_FILE"
                echo "false" > "$GESTURE_ACTIVE_FILE"
                gesture_active=false
                finger_count=0
                motion_counter=0
                sleep 0.3  # Prevent multiple triggers
            fi
        fi
        done
        
        echo "$(date): libinput monitor died, restarting in 2 seconds..." >> /tmp/touch-gesture.log
        sleep 2
    done
}

monitor_touch