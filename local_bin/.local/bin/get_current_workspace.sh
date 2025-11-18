#!/bin/bash

# Get current workspace number using swaymsg
current_num=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .num')

case "$1" in
    "next")
        echo $((current_num + 1))
        ;;
    "prev")
        echo $((current_num - 1))
        ;;
    *)
        echo "$current_num"
        ;;
esac