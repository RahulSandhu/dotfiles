#!/bin/bash

# Physical keyboards only: skip the wvkbd virtual keyboard
CURRENT_LAYOUT=$(swaymsg -t get_inputs |
    jq -r '[.[] | select(.type == "keyboard" and .name != "wlr_virtual_keyboard_v1")][0].xkb_active_layout_name')

if [[ "$CURRENT_LAYOUT" == "Spanish" ]]; then
    echo true
else
    echo false
fi
