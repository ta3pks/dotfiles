#!/bin/bash

echo "=== Gesture Detection Monitor ==="
echo "Try swiping up/down with 3 fingers on the touchscreen"
echo "Press Ctrl+C to stop monitoring"
echo ""

# Monitor journalctl for fusuma logs in real-time
journalctl --user -f -u fusuma 2>/dev/null | grep --line-buffered -E "(command|gesture|swipe)" || \
journalctl --user -f | grep --line-buffered -E "(fusuma|command|gesture|swipe)"