#!/bin/bash
# Fixed-width network speed display

iface=$(ip route | awk '/default/ {print $5; exit}')
[ -z "$iface" ] && echo "↓ ------ ↑ ------" && exit 0

stats_file="/dev/shm/netspeed_$iface"

# Check if interface is up, clean stale stats if not
if ! ip link show "$iface" 2>/dev/null | grep -q "state UP"; then
    echo "↓ ------ ↑ ------"
    rm -f "$stats_file" 2>/dev/null
    exit 0
fi
rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
now=$(date +%s)

if [ -f "$stats_file" ]; then
    read -r prev_rx prev_tx prev_time < "$stats_file"
    dt=$((now - prev_time))
    if [ $dt -gt 0 ]; then
        rx_speed=$(( (rx - prev_rx) / dt ))
        tx_speed=$(( (tx - prev_tx) / dt ))
        [ $rx_speed -lt 0 ] && rx_speed=0
        [ $tx_speed -lt 0 ] && tx_speed=0
    else
        rx_speed=0
        tx_speed=0
    fi
else
    rx_speed=0
    tx_speed=0
fi

echo "$rx $tx $now" > "$stats_file"

format_speed() {
    local speed=$1
    if [ $speed -ge 1048576 ]; then
        printf "%5.1fM" $(awk "BEGIN {printf \"%.1f\", $speed/1048576}")
    elif [ $speed -ge 1024 ]; then
        printf "%5.0fK" $(awk "BEGIN {printf \"%.0f\", $speed/1024}")
    else
        printf "%5dB" $speed
    fi
}

echo "↓$(format_speed $rx_speed) ↑$(format_speed $tx_speed)"
