#!/bin/bash
cpu_hwmon="/sys/devices/pci0000:00/0000:00:18.3/hwmon"
gpu_hwmon="/sys/devices/pci0000:00/0000:00:08.1/0000:c4:00.0/hwmon"

cpu_temp=$(cat "$cpu_hwmon"/hwmon*/temp1_input 2>/dev/null)
gpu_temp=$(cat "$gpu_hwmon"/hwmon*/temp1_input 2>/dev/null)

cpu_c=$((cpu_temp / 1000))
gpu_c=$((gpu_temp / 1000))

if [ "$cpu_c" -ge 90 ]; then
    icon="🔥"
    class="critical"
elif [ "$cpu_c" -ge 75 ]; then
    icon="🥵"
    class="warning"
else
    icon="🌡️"
    class="normal"
fi

printf '{"text": "%s %d°C", "tooltip": "CPU: %d°C\\nGPU: %d°C", "class": "%s"}\n' \
    "$icon" "$cpu_c" "$cpu_c" "$gpu_c" "$class"
