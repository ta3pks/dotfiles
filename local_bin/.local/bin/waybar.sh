# Change this according to your device
################
# Variables
################

# Date and time
day_name=$(date "+%a")
week_number=$(date "+w%-V")
date_and_week=$(date "+%Y/%m/%d")
current_time=$(date "+%H:%M")

#############
# Commands
#############

# Battery or charger
battery_charge=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "percentage" | awk '{print $2}')
battery_status=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state" | awk '{print $2}')

# Audio and multimedia

# Network connection status using nmcli
active_connection=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | head -1)
if [ -n "$active_connection" ]; then
    conn_name=$(echo "$active_connection" | cut -d':' -f1)
    conn_type=$(echo "$active_connection" | cut -d':' -f2)
    conn_device=$(echo "$active_connection" | cut -d':' -f3)
    
    case $conn_type in
        "802-11-wireless")
            # WiFi connection
            signal=$(nmcli -t -f SIGNAL device wifi | head -1)
            local_ip=$(ip -4 addr show $conn_device 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$signal" ] && [ -n "$local_ip" ]; then
                network_status="📶 ${conn_name} ${local_ip} (${signal}%)"
            elif [ -n "$local_ip" ]; then
                network_status="📶 ${conn_name} ${local_ip}"
            else
                network_status="📶 ${conn_name}"
            fi
            ;;
        "802-3-ethernet")
            # Ethernet connection - show local IP
            local_ip=$(ip -4 addr show $conn_device 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$local_ip" ]; then
                network_status="🌐 ${local_ip}"
            else
                network_status="🌐 ${conn_name}"
            fi
            ;;
        *)
            # Other connection types - show local IP
            local_ip=$(ip -4 addr show $conn_device 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$local_ip" ]; then
                network_status="🔗 ${local_ip}"
            else
                network_status="🔗 ${conn_name}"
            fi
            ;;
    esac
else
    # No active connection
    network_status="❌ No Connection"
fi

# Network speed monitoring
if [ -n "$conn_device" ]; then
    # Get current network stats
    stats_file="/tmp/netstats_${conn_device}"
    current_rx=$(cat /sys/class/net/$conn_device/statistics/rx_bytes 2>/dev/null || echo 0)
    current_tx=$(cat /sys/class/net/$conn_device/statistics/tx_bytes 2>/dev/null || echo 0)
    current_time_epoch=$(date +%s)
    
    if [ -f "$stats_file" ]; then
        # Read previous stats (format: rx:tx:time)
        prev_data=$(cat "$stats_file")
        prev_rx=$(echo "$prev_data" | cut -d':' -f1)
        prev_tx=$(echo "$prev_data" | cut -d':' -f2)
        prev_time=$(echo "$prev_data" | cut -d':' -f3)
        
        # Calculate speeds (bytes per second)
        time_diff=$((current_time_epoch - prev_time))
        if [ $time_diff -gt 0 ]; then
            rx_diff=$((current_rx - prev_rx))
            tx_diff=$((current_tx - prev_tx))
            
            # Handle negative values (interface reset, etc.)
            if [ $rx_diff -lt 0 ]; then rx_diff=0; fi
            if [ $tx_diff -lt 0 ]; then tx_diff=0; fi
            
            # Convert to human readable format
            rx_speed=$((rx_diff / time_diff))
            tx_speed=$((tx_diff / time_diff))
            
            # Convert to bits per second for speed test compatibility
            rx_speed_bits=$((rx_speed * 8))
            tx_speed_bits=$((tx_speed * 8))
            
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
            
            network_speed="↓$rx_display ↑$tx_display"
        else
            network_speed="↓0bps ↑0bps"
        fi
    else
        network_speed="↓0bps ↑0bps"
    fi
    
    # Save current stats for next iteration (format: rx:tx:time)
    echo "${current_rx}:${current_tx}:${current_time_epoch}" > "$stats_file"
else
    network_speed="↓0bps ↑0bps"
fi

# Keep ping as backup connectivity check
ping=$(ping -c 1 www.google.com 2>/dev/null | tail -1 | awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)
if [ -z "$ping" ]; then
    ping="N/A"
fi

# Others
loadavg_1min=$(cat /proc/loadavg | awk -F ' ' '{print $1}')
loadavg_5min=$(cat /proc/loadavg | awk -F ' ' '{print $2}')
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
memory_usage=$(free -h | awk '/^Mem:/ {used=$3; total=$2; gsub(/Gi/, "", used); gsub(/Gi/, "", total); printf "%.0f%% (%s/%sG)", $3/$2 * 100.0, used, total}')

# Current keyboard layout
layout_name=$(swaymsg -t get_inputs | jq -r '.[] | select(.type == "keyboard") | .xkb_active_layout_name' | grep -v null | head -1 | cut -d ' ' -f1)
case $layout_name in
    "Turkish") current_layout="T" ;;
    "Russian") current_layout="R" ;;
    *) current_layout="$layout_name" ;;
esac

# Removed weather because we are requesting it too many times to have a proper
# refresh on the bar
#weather=$(curl -Ss 'https://wttr.in/Pontevedra?0&T&Q&format=1')

if [ $battery_status = "discharging" ]; then
	battery_pluggedin='⚠'
else
	battery_pluggedin='⚡'
fi

echo "$network_status $network_speed | Ping: $ping ms | $current_layout | 🏋 $loadavg_1min/$loadavg_5min | 🖥️ $cpu_usage | 💾 $memory_usage | $battery_pluggedin $battery_charge | ($week_number) $date_and_week $day_name 🕘 $current_time"
