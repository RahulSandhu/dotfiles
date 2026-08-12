#!/bin/bash

APP_ID="eu.betterbird.Betterbird"
STATE_FILE="/tmp/betterbird_visible_state"

# Ensure SWAYSOCK is set for swaymsg
if [ -z "$SWAYSOCK" ]; then
    export SWAYSOCK=$(ls /run/user/$(id - u)/sway-ipc.*.sock 2>/dev/null | head -1)
fi

# Check if Betterbird is running (use pidof to avoid matching the script filename)
if ! /usr/bin/pidof betterbird >/dev/null 2>&1; then
    rm -f "$STATE_FILE"
    /usr/bin/betterbird &
    # Wait for window to appear and mark as visible
    for i in {1..30}; do
        sleep 0.3
        ID=$(/usr/bin/swaymsg -t get_tree 2>/dev/null | /usr/bin/jq -r ".. | objects | select(.app_id? == \"$APP_ID\") | .id" 2>/dev/null)
        if [ -n "$ID" ] && [ "$ID" != "null" ]; then
            touch "$STATE_FILE"
            exit 0
        fi
    done
    exit 1
fi

# Get window ID
ID=$(/usr/bin/swaymsg -t get_tree 2>/dev/null | /usr/bin/jq -r ".. | objects | select(.app_id? == \"$APP_ID\") | .id" 2>/dev/null)

if [ -z "$ID" ] || [ "$ID" = "null" ]; then
    exit 1
fi

# Toggle based on state file
if [ -f "$STATE_FILE" ]; then
    # Currently marked as visible — hide it
    rm -f "$STATE_FILE"
    /usr/bin/swaymsg "[con_id=\"$ID\"] move to scratchpad" 2>/dev/null
else
    # Currently hidden — show it and center on screen
    touch "$STATE_FILE"
    /usr/bin/swaymsg "[con_id=\"$ID\"] scratchpad show" 2>/dev/null
    sleep 0.1

    # Resize window to 70% of focused output dimensions (30% smaller)
    read W_PX H_PX < <(/usr/bin/swaymsg -t get_outputs 2>/dev/null | /usr/bin/jq -r '.[] | select(.focused) | "\(.rect.width * 0.7 | floor) \(.rect.height * 0.7 | floor)"')
    /usr/bin/swaymsg "[con_id=\"$ID\"] resize set ${W_PX}px ${H_PX}px" 2>/dev/null

    /usr/bin/swaymsg "[con_id=\"$ID\"] move position center" 2>/dev/null
fi
