#!/bin/bash

# Get the output where the pip window is currently located
pip_output=$(swaymsg -t get_tree | jq -r '.. | objects | select(.name? and (.name | test("Picture in picture"; "i"))) | .output' | head -1)

# If pip window not found, use focused output
if [ "$pip_output" = "null" ] || [ -z "$pip_output" ]; then
	pip_output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name' | head -1)
fi

# Get screen width and scale factor for the pip window's output
screen_width=$(swaymsg -t get_outputs | jq -r ".[] | select(.name==\"$pip_output\") | .current_mode.width")
scale=$(swaymsg -t get_outputs | jq -r ".[] | select(.name==\"$pip_output\") | .scale")

# Calculate effective width accounting for scale
effective_width=$(echo "scale=0; $screen_width / $scale" | bc)

# Calculate position: right edge - 30px - window_width
window_width=700
window_height=400
margin=30
position=$(echo "scale=0; $effective_width - $window_width - $margin" | bc)

echo "Output: $pip_output, Screen width: $screen_width, Scale: $scale, Effective width: $effective_width, Position: $position"

# Apply to pip window with absolute positioning
# Apply to pip window with absolute positioning
swaymsg '[title="Picture in picture"] floating enable, sticky enable, resize set '"$window_width"' '"$window_height"', move absolute position '"$position"' 100'
swaymsg '[app_id="mpv"] floating enable, sticky enable, resize set '"$window_width"' '"$window_height"', move absolute position '"$position"' 100'
