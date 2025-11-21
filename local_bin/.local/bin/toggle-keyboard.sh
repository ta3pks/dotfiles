#!/bin/bash

if pgrep -f "wvkbd-mobintl" > /dev/null; then
    # Running - kill it
    killall wvkbd-mobintl
else
    # Not running - start it normally
    wvkbd-mobintl &
fi