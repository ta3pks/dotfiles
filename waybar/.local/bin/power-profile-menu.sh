#!/bin/bash

current=$(asusctl profile get | head -1 | awk '{print $NF}')

choice=$(printf "🔋 Quiet\n⚖️ Balanced\n🚀 Performance" | rofi -dmenu -p "Profile ($current)" -me-select-entry '' -me-accept-entry 'MousePrimary' -theme-str 'window {width: 250px;} element {padding: 8px;}')

case "$choice" in
    *Quiet) asusctl profile set Quiet ;;
    *Balanced) asusctl profile set Balanced ;;
    *Performance) asusctl profile set Performance ;;
esac
