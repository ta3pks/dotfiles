#!/bin/bash

# Toggle enable/disable for eDP-1 builtin display
current_power=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.name == "eDP-1") | .power')

if [ "$current_power" = "true" ]; then
    swaymsg output eDP-1 disable
else
    swaymsg output eDP-1 enable
fi