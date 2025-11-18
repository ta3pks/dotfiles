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

# Network
# interface_easyname grabs the "old" interface name before systemd renamed it
# interface_easyname=$(dmesg | grep $network | grep renamed | awk 'NF>1{print $NF}')
ping=$(ping -c 1 www.google.com | tail -1 | awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)

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

echo "🌐 $current_layout | Ping: $ping ms | 🏋 $loadavg_1min/$loadavg_5min | 🖥️ $cpu_usage | 💾 $memory_usage | $battery_pluggedin $battery_charge | ($week_number) $date_and_week $day_name 🕘 $current_time"
