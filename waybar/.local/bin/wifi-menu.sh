#!/bin/bash

# Rofi-based wifi menu for NetworkManager

notify() {
    notify-send "WiFi" "$1" 2>/dev/null || echo "$1"
}

# Scan for networks
nmcli device wifi rescan 2>/dev/null

# Get list of wifi networks
networks=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | grep -v '^--' | sort -t: -k2 -nr | uniq)

if [ -z "$networks" ]; then
    notify "No WiFi networks found"
    exit 1
fi

# Format for rofi: SSID (signal%) [security]
formatted=""
while IFS=: read -r ssid signal security; do
    [ -z "$ssid" ] && continue
    if [ -z "$security" ] || [ "$security" = "--" ]; then
        security="Open"
    fi
    formatted+="${ssid}  ${signal}%  [${security}]\n"
done <<< "$networks"

# Show rofi menu
chosen=$(echo -e "$formatted" | rofi -dmenu -i -p "WiFi" -theme-str 'window {width: 400px;}')

[ -z "$chosen" ] && exit 0

# Extract SSID (everything before the first double space)
ssid=$(echo "$chosen" | sed 's/  .*//')

# Get saved wifi connections (single nmcli call, filter wifi only)
saved_connections=$(nmcli -t -f NAME,ACTIVE,TYPE connection show | grep ':802-11-wireless$' | cut -d: -f1,2)
current=$(echo "$saved_connections" | awk -F: '$2=="yes" {print $1; exit}')

if [ "$current" = "$ssid" ]; then
    notify "Already connected to $ssid"
    exit 0
fi

# Check if we have a saved connection
if echo "$saved_connections" | cut -d: -f1 | grep -q "^${ssid}$"; then
    notify "Connecting to $ssid..."
    nmcli connection up "$ssid" && notify "Connected to $ssid" || notify "Failed to connect to $ssid"
    exit 0
fi

# Check if network needs password
security=$(echo "$chosen" | grep -oP '\[\K[^\]]+')
if [ "$security" != "Open" ]; then
    password=$(rofi -dmenu -p "Password for $ssid" -password -theme-str 'window {width: 400px;}')
    [ -z "$password" ] && exit 0
    notify "Connecting to $ssid..."
    nmcli device wifi connect "$ssid" password "$password" && notify "Connected to $ssid" || notify "Failed to connect to $ssid"
else
    notify "Connecting to $ssid..."
    nmcli device wifi connect "$ssid" && notify "Connected to $ssid" || notify "Failed to connect to $ssid"
fi
