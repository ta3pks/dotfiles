#!/bin/bash

# Get current network stats
stats_file="/tmp/netstats_bits"
conn_device=$(nmcli -t -f DEVICE connection show --active | cut -d':' -f1 | head -1)

if [ -z "$conn_device" ]; then
    echo "↓0bps ↑0bps"
    exit 0
fi

current_rx=$(cat /sys/class/net/$conn_device/statistics/rx_bytes 2>/dev/null || echo 0)
current_tx=$(cat /sys/class/net/$conn_device/statistics/tx_bytes 2>/dev/null || echo 0)
current_time_epoch=$(date +%s)

if [ -f "$stats_file" ]; then
    prev_data=$(cat "$stats_file")
    prev_rx=$(echo "$prev_data" | cut -d':' -f1)
    prev_tx=$(echo "$prev_data" | cut -d':' -f2)
    prev_time=$(echo "$prev_data" | cut -d':' -f3)
    
    time_diff=$((current_time_epoch - prev_time))
    if [ $time_diff -gt 0 ]; then
        rx_diff=$((current_rx - prev_rx))
        tx_diff=$((current_tx - prev_tx))
        
        if [ $rx_diff -lt 0 ]; then rx_diff=0; fi
        if [ $tx_diff -lt 0 ]; then tx_diff=0; fi
        
        # Convert to bits per second
        rx_speed_bits=$(((rx_diff * 8) / time_diff))
        tx_speed_bits=$(((tx_diff * 8) / time_diff))
        
        # Format download speed (in bits)
        if [ $rx_speed_bits -gt 1048576 ]; then
            rx_display=$(awk "BEGIN {printf \"%.1f\", $rx_speed_bits/1048576}")Mbps
        elif [ $rx_speed_bits -gt 1024 ]; then
            rx_display=$(awk "BEGIN {printf \"%.0f\", $rx_speed_bits/1024}")Kbps
        else
            rx_display="${rx_speed_bits}bps"
        fi
        
        # Format upload speed (in bits)
        if [ $tx_speed_bits -gt 1048576 ]; then
            tx_display=$(awk "BEGIN {printf \"%.1f\", $tx_speed_bits/1048576}")Mbps
        elif [ $tx_speed_bits -gt 1024 ]; then
            tx_display=$(awk "BEGIN {printf \"%.0f\", $tx_speed_bits/1024}")Kbps
        else
            tx_display="${tx_speed_bits}bps"
        fi
        
        echo "↓$rx_display ↑$tx_display"
    else
        echo "↓0bps ↑0bps"
    fi
else
    echo "↓0bps ↑0bps"
fi

echo "${current_rx}:${current_tx}:${current_time_epoch}" > "$stats_file"
