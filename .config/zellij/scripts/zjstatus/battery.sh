#!/usr/bin/env bash

charging_icon=""
percentage_0=""
percentage_1=""
percentage_2=""
percentage_3=""
percentage_4=""
missing_icon="󱉝"

# Find first available battery
capacity=""
status=""
for bat in /sys/class/power_supply/BAT*; do
    if [ -f "$bat/capacity" ]; then
        capacity=$(cat "$bat/capacity" 2>/dev/null)
        if [ -f "$bat/status" ]; then
            status=$(cat "$bat/status" 2>/dev/null)
        fi
        break
    fi
done

if [ -z "$capacity" ]; then
    echo "$missing_icon ?"
    exit 0
fi

# Select icon based on percentage
if [ "$capacity" -gt 90 ]; then
    icon="$percentage_4"
elif [ "$capacity" -gt 75 ]; then
    icon="$percentage_3"
elif [ "$capacity" -gt 50 ]; then
    icon="$percentage_2"
elif [ "$capacity" -gt 25 ]; then
    icon="$percentage_1"
elif [ "$capacity" -gt 10 ]; then
    icon="$percentage_0"
else
    icon="$percentage_0"
fi

# Charging indicator
case "$status" in
    Charging|charging)
        echo "$charging_icon $icon ${capacity}%"
        ;;
    *)
        echo "$icon ${capacity}%"
        ;;
esac
