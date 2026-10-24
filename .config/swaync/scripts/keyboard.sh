#!/bin/bash

# Physical keyboards only: skip the wvkbd virtual keyboard
mapfile -t DEVICES < <(
    swaymsg -t get_inputs |
        jq -r '.[] | select(.type == "keyboard" and .name != "wlr_virtual_keyboard_v1") | .identifier'
)

for id in "${DEVICES[@]}"; do
    swaymsg input "$id" xkb_switch_layout next >/dev/null
done

CURRENT_LAYOUT=$(swaymsg -t get_inputs |
    jq -r --arg id "${DEVICES[0]}" '.[] | select(.identifier == $id) | .xkb_active_layout_name')

notify-send \
    --app-name="Sway" \
    --icon=input-keyboard-symbolic \
    --urgency=low \
    --expire-time=3000 \
    --replace-id=9992 \
    "Keyboard Layout" "Switched to $CURRENT_LAYOUT"
