#!/bin/bash

KEYBOARD_BIN="$HOME/.local/bin/wvkbd-mobintl-custom"

if pgrep -f "wvkbd-mobintl-custom" > /dev/null; then
    killall wvkbd-mobintl-custom
else
    "$KEYBOARD_BIN" -L 250 &
fi