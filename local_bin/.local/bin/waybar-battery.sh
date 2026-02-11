#!/bin/bash
bat="/sys/class/power_supply/BAT0"

capacity=$(cat "$bat/capacity" 2>/dev/null || echo 0)
status=$(cat "$bat/status" 2>/dev/null || echo "Unknown")
power_now=$(cat "$bat/power_now" 2>/dev/null || echo 0)
energy_now=$(cat "$bat/energy_now" 2>/dev/null || echo 0)
energy_full=$(cat "$bat/energy_full" 2>/dev/null || echo 0)

power_w=$(awk "BEGIN {printf \"%.1f\", $power_now / 1000000}")

# Time remaining
time_str=""
if [ "$status" = "Discharging" ] && [ "$power_now" -gt 0 ]; then
    hours=$(awk "BEGIN {printf \"%d\", $energy_now / $power_now}")
    mins=$(awk "BEGIN {printf \"%d\", ($energy_now / $power_now - int($energy_now / $power_now)) * 60}")
    time_str="Time to empty: ${hours}h ${mins}m"
elif [ "$status" = "Charging" ] && [ "$power_now" -gt 0 ]; then
    remaining=$((energy_full - energy_now))
    hours=$(awk "BEGIN {printf \"%d\", $remaining / $power_now}")
    mins=$(awk "BEGIN {printf \"%d\", ($remaining / $power_now - int($remaining / $power_now)) * 60}")
    time_str="Time to full: ${hours}h ${mins}m"
fi

# Uptime
uptime_str=$(uptime -p | sed 's/^up //')

# Icon and class
if [ "$status" = "Charging" ] || [ "$status" = "Full" ] || [ "$status" = "Not charging" ]; then
    icon="🔌"
    class="charging"
elif [ "$capacity" -le 15 ]; then
    icon="🪫"
    class="critical"
elif [ "$capacity" -le 30 ]; then
    icon="🔋"
    class="warning"
else
    icon="🔋"
    class="normal"
fi

# Format text
if [ "$status" = "Full" ] || [ "$status" = "Not charging" ]; then
    text="$icon ${capacity}%"
else
    text="$icon ${capacity}% ${power_w}W"
fi

# Build tooltip
tooltip="${capacity}% - ${power_w}W"
[ -n "$time_str" ] && tooltip="$time_str\\n$tooltip"
tooltip="$tooltip\\nUptime: $uptime_str"

printf '{"text": "%s", "tooltip": "%s", "class": "%s", "percentage": %d}\n' \
    "$text" "$tooltip" "$class" "$capacity"
