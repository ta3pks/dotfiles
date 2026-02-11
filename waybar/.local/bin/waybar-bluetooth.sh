#!/bin/bash
powered=$(bluetoothctl show 2>/dev/null | grep -i "Powered:" | awk '{print $2}')
connected=$(bluetoothctl devices Connected 2>/dev/null)

if [ "$powered" != "yes" ]; then
    printf '{"text": "󰂲", "tooltip": "Bluetooth off (click to enable)", "class": "off"}\n'
    exit 0
fi

if [ -n "$connected" ]; then
    devices=$(echo "$connected" | sed 's/Device [^ ]* //' | paste -sd ', ')
    printf '{"text": "󰂯", "tooltip": "Connected: %s", "class": "connected"}\n' "$devices"
else
    printf '{"text": "󰂰", "tooltip": "Bluetooth on, no devices connected", "class": "on"}\n'
fi
