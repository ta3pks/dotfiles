#!/bin/bash

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: battery_since_charge.sh [--seconds|--json|--tooltip]

Reports how long the system has been running on battery since the last AC
power transition recorded by UPower.
EOF
}

find_device() {
    local pattern="$1"
    upower -e | awk -v pat="$pattern" '$0 ~ pat { print; exit }'
}

format_duration() {
    local total_seconds="$1"
    local hours minutes seconds

    if (( total_seconds < 0 )); then
        total_seconds=0
    fi

    hours=$((total_seconds / 3600))
    minutes=$(((total_seconds % 3600) / 60))
    seconds=$((total_seconds % 60))

    if (( hours > 0 )); then
        printf '%dh %02dm %02ds\n' "$hours" "$minutes" "$seconds"
    elif (( minutes > 0 )); then
        printf '%dm %02ds\n' "$minutes" "$seconds"
    else
        printf '%ds\n' "$seconds"
    fi
}

mode="${1:-human}"
case "$mode" in
    human|--seconds|--json|--tooltip|"")
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 1
        ;;
esac

battery_device="$(find_device '/battery_')"
ac_device="$(find_device '/line_power_AC')"

if [[ -z "$battery_device" ]]; then
    echo "Battery device not found via upower" >&2
    exit 1
fi

if [[ -z "$ac_device" ]]; then
    echo "AC line-power device not found via upower" >&2
    exit 1
fi

battery_info="$(LC_ALL=C upower -i "$battery_device")"
ac_info="$(LC_ALL=C upower -i "$ac_device")"

ac_online="$(sed -n 's/^[[:space:]]*online:[[:space:]]*//p' <<<"$ac_info" | head -1)"
battery_state="$(sed -n 's/^[[:space:]]*state:[[:space:]]*//p' <<<"$battery_info" | head -1)"
battery_percentage="$(sed -n 's/^[[:space:]]*percentage:[[:space:]]*//p' <<<"$battery_info" | head -1 | tr -d '%')"
ac_updated_raw="$(sed -n 's/^[[:space:]]*updated:[[:space:]]*//p' <<<"$ac_info" | head -1 | sed 's/ ([^()]*)$//')"

if [[ "$ac_online" == "yes" || "$battery_state" == "charging" || "$battery_state" == "fully-charged" ]]; then
    case "$mode" in
        --seconds)
            echo "0"
            ;;
        --json)
            printf '{"on_battery":false,"seconds":0,"text":"AC","tooltip":"On AC power","battery_percentage":"%s"}\n' "${battery_percentage:-unknown}"
            ;;
        --tooltip)
            echo "On AC power"
            ;;
        *)
            echo "On AC power"
            ;;
    esac
    exit 0
fi

if [[ -z "$ac_updated_raw" ]]; then
    echo "Could not parse the last AC update time from upower" >&2
    exit 1
fi

start_epoch="$(date -d "$ac_updated_raw" +%s)"
now_epoch="$(date +%s)"
elapsed_seconds=$((now_epoch - start_epoch))

if (( elapsed_seconds < 0 )); then
    elapsed_seconds=0
fi

start_display="$(date -d "@$start_epoch" '+%Y-%m-%d %H:%M:%S %Z')"
elapsed_human="$(format_duration "$elapsed_seconds")"
elapsed_human="${elapsed_human%$'\n'}"

case "$mode" in
    --seconds)
        echo "$elapsed_seconds"
        ;;
    --json)
        printf '{"on_battery":true,"seconds":%d,"text":"%s","tooltip":"On battery since %s (%s)","battery_percentage":"%s"}\n' \
            "$elapsed_seconds" "$elapsed_human" "$start_display" "$battery_state" "${battery_percentage:-unknown}"
        ;;
    --tooltip)
        printf 'On battery since %s (%s)\n' "$start_display" "$elapsed_human"
        ;;
    *)
        echo "$elapsed_human"
        ;;
esac
