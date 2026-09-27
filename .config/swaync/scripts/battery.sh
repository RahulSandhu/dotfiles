#!/bin/bash

# Single-instance lock 
exec 9>/tmp/battery.lock
flock -n 9 || exit 0

# Define an ID
ID=999

# Main loop to check battery periodically
while true; do
    PERCENT=$(cat /sys/class/power_supply/BAT1/capacity)
    STATUS=$(cat /sys/class/power_supply/BAT1/status)
    if [[ "$STATUS" == "Discharging" && "$PERCENT" -le 20 ]]; then
        notify-send \
            --app-name="Sway" \
            --icon=battery-caution \
            --urgency=critical \
            --expire-time=0 \
            --replace-id="$ID" \
            "Battery Low: ${PERCENT}%" "Discharging — plug in charger"
    elif [[ "$STATUS" == "Charging" && "$PERCENT" -ge 80 ]]; then
        notify-send \
            --app-name="Sway" \
            --icon=battery-good \
            --urgency=normal \
            --expire-time=5000 \
            --replace-id="$ID" \
            "Battery Charged: ${PERCENT}%" "Charging — unplug charger"
    fi
    sleep 300 
done
