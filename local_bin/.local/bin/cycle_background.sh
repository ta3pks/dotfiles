#!/bin/bash

# Cycle background images in a folder
# Usage: cycle_background.sh /path/to/images interval_in_minutes

IMAGE_DIR="${1:-$HOME/Pictures/Wallpapers}"
INTERVAL="${2:-5}"  # Default 5 minutes

# Convert minutes to seconds for sleep
INTERVAL_SECONDS=$((INTERVAL * 60))

while true; do
    # Get random image from directory
    if [ -d "$IMAGE_DIR" ]; then
        IMAGE=$(find "$IMAGE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.webp" \) | shuf -n 1)
        
        if [ -n "$IMAGE" ]; then
            swaybg -i "$IMAGE" &
            SWAYBG_PID=$!
            
            # Kill swaybg after interval to allow next image
            sleep "$INTERVAL_SECONDS"
            kill $SWAYBG_PID 2>/dev/null
        else
            echo "No images found in $IMAGE_DIR"
            sleep 60
        fi
    else
        echo "Directory $IMAGE_DIR does not exist"
        sleep 60
    fi
done