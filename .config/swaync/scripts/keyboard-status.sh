#!/bin/bash

# Get and check the current keyboard layout in Sway
CURRENT_LAYOUT=$(swaymsg -t get_inputs | jq -r '.. | objects | select(.type? == "keyboard") | .xkb_active_layout_name' | head -n1)

# Logic to determine if the layout is Spanish
if [[ "$CURRENT_LAYOUT" == "Spanish" ]]; then
    echo true
else
    echo false
fi
