#!/bin/bash

# Background touch gesture service with proper process management
# This script runs touch gesture monitor in background

SCRIPT_DIR="/home/nikos/dotfiles/local_bin/.local/bin"
TOUCH_MONITOR="$SCRIPT_DIR/gesture_recognition.sh"
PID_FILE="/tmp/touch-gesture.pid"
LOCK_FILE="/tmp/touch-gesture.lock"

start_monitor() {
    # Check if already running using lock file
    if [ -f "$LOCK_FILE" ]; then
        echo "Touch gesture monitor is already running"
        return 0
    fi
    
    # Create lock file
    touch "$LOCK_FILE"
    
    echo "Starting touch gesture monitor..."
    # Run with logging to help debug issues
    "$TOUCH_MONITOR" >> /tmp/touch-gesture.log 2>&1 &
    local pid=$!
    echo "$pid" > "$PID_FILE"
    echo "Touch gesture monitor started (PID: $pid)"
}

stop_monitor() {
    # Kill all gesture recognition processes
    pkill -f "gesture_recognition" 2>/dev/null
    
    # Remove lock and PID files
    rm -f "$LOCK_FILE"
    rm -f "$PID_FILE"
    echo "Touch gesture monitor stopped"
}

status_monitor() {
    if [ -f "$LOCK_FILE" ]; then
        echo "Touch gesture monitor is running"
        if [ -f "$PID_FILE" ]; then
            echo "PID: $(cat $PID_FILE)"
        fi
    else
        echo "Touch gesture monitor is not running"
    fi
}

case "$1" in
    start)
        start_monitor
        ;;
    stop)
        stop_monitor
        ;;
    restart)
        stop_monitor
        sleep 1
        start_monitor
        ;;
    status)
        status_monitor
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac