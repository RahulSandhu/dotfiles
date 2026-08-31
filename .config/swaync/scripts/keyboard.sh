#!/bin/bash

CURRENT_LAYOUT=$(swaymsg -t get_inputs | jq -r '.. | objects | select(.type? == "keyboard") | .xkb_active_layout_name' | head -n1)

if [[ "$CURRENT_LAYOUT" == "English (US)" ]]; then
    swaymsg input type:keyboard xkb_layout es
    NEW_LAYOUT="Spanish (ES)"
else
    swaymsg input type:keyboard xkb_layout us
    NEW_LAYOUT="English (EN)"
fi

notify-send \
    --app-name="Sway" \
    --icon=input-keyboard-symbolic \
    --urgency=low \
    --expire-time=3000 \
    --replace-id=9992 \
    "Keyboard Layout" "Switched to $NEW_LAYOUT"
