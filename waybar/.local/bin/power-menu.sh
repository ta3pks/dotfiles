#!/bin/bash

choice=$(printf "⏻ Power Off\n🔄 Reboot\n❄ Hibernate\n💤 Sleep" | rofi -dmenu -p "Power" -me-select-entry '' -me-accept-entry 'MousePrimary' -theme-str 'window {width: 200px;} element {padding: 8px;}')

case "$choice" in
    "⏻ Power Off") systemctl poweroff ;;
    "🔄 Reboot") systemctl reboot ;;
    "❄ Hibernate") systemctl hibernate ;;
    "💤 Sleep") systemctl suspend-then-hibernate ;;
esac
