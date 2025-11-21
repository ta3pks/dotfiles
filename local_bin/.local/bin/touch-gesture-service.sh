#!/bin/bash

# Background touch gesture service
# This script runs the touch gesture monitor in the background

SCRIPT_DIR="/home/nikos/dotfiles/local_bin/.local/bin"
TOUCH_MONITOR="$SCRIPT_DIR/touch-gesture.sh"
PID_FILE="/tmp/touch-gesture.pid"

start_monitor() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "Touch gesture monitor is already running (PID: $(cat $PID_FILE))"
        return 0
    fi
    
    echo "Starting touch gesture monitor..."
    nohup "$TOUCH_MONITOR" > /dev/null 2>&1 &
    echo $! > "$PID_FILE"
    echo "Touch gesture monitor started (PID: $(cat $PID_FILE))"
}

stop_monitor() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            echo "Touch gesture monitor stopped (PID: $PID)"
        else
            echo "Touch gesture monitor was not running"
        fi
        rm -f "$PID_FILE"
    else
        echo "No PID file found - monitor may not be running"
    fi
}

status_monitor() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "Touch gesture monitor is running (PID: $(cat $PID_FILE))"
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