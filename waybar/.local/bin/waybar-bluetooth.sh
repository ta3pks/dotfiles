#!/bin/bash

adapter="/org/bluez/hci0"
powered=$(busctl get-property org.bluez "$adapter" org.bluez.Adapter1 Powered 2>/dev/null | awk '{print $2}')

if [ "$powered" != "true" ]; then
    printf '{"text": "󰂲", "tooltip": "Bluetooth off (click to enable)", "class": "off"}\n'
    exit 0
fi

connected=$(busctl call org.bluez / org.bluez.AgentManager1 RegisteredApp 2>/dev/null)
devices=$(busctl tree org.bluez --list 2>/dev/null | grep -E '/org/bluez/hci0/dev_' | while read -r path; do
    name=$(busctl get-property org.bluez "$path" org.bluez.Device1 Name 2>/dev/null | sed 's/s "\(.*\)"/\1/')
    is_connected=$(busctl get-property org.bluez "$path" org.bluez.Device1 Connected 2>/dev/null | awk '{print $2}')
    if [ "$is_connected" = "true" ] && [ -n "$name" ]; then
        echo "$name"
    fi
done)

if [ -n "$devices" ]; then
    devices_str=$(echo "$devices" | paste -sd ', ')
    printf '{"text": "󰂯", "tooltip": "Connected: %s", "class": "connected"}\n' "$devices_str"
else
    printf '{"text": "󰂰", "tooltip": "Bluetooth on, no devices connected", "class": "on"}\n'
fi
