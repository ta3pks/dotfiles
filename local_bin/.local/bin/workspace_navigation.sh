#!/bin/bash

# Workspace navigation script
# Usage: workspace_navigation.sh [next|prev] [move|focus]

ACTION="${1:-focus}"
DIRECTION="${2:-next}"

# Get current workspace number
current_num=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .num')

# Calculate target workspace
case "$DIRECTION" in
    "next")
        target_num=$((current_num + 1))
        ;;
    "prev")
        target_num=$((current_num - 1))
        ;;
    *)
        target_num="$current_num"
        ;;
esac

# Perform action
case "$ACTION" in
    "move")
        swaymsg move container to workspace number "$target_num"
        swaymsg workspace number "$target_num"
        ;;
    "focus"|*)
        swaymsg workspace number "$target_num"
        ;;
esac