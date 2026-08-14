#!/bin/bash

CONFIG_FILE="${HOME}/.config/swaync/config.json"
CACHE_FILE="/tmp/swaync-battery-status"

get_icon() {
    local pct=$1
    local status=$2
    if [[ "$status" == "Charging" ]]; then
        echo "󰂄"
        return
    fi
    if [[ "$pct" -ge 80 ]]; then
        echo "󰁹"
    elif [[ "$pct" -ge 50 ]]; then
        echo "󰁿"
    else
        echo "󰁻"
    fi
}

main_loop() {
    while true; do
        if [[ -r /sys/class/power_supply/BAT1/capacity ]]; then
            PCT=$(cat /sys/class/power_supply/BAT1/capacity)
            STATUS=$(cat /sys/class/power_supply/BAT1/status 2>/dev/null || echo "Unknown")
            ICON=$(get_icon "$PCT" "$STATUS")
            NEW_TEXT="${ICON} ${PCT}%"

            if [[ ! -f "$CACHE_FILE" ]] || [[ "$(cat "$CACHE_FILE")" != "$NEW_TEXT" ]]; then
                echo "$NEW_TEXT" > "$CACHE_FILE"
                jq --arg txt "$NEW_TEXT" '.
                    | .["widget-config"]["title"]["text"] = $txt
                ' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
                swaync-client -R 2>/dev/null
            fi
        fi
        sleep 30
    done
}

main_loop
