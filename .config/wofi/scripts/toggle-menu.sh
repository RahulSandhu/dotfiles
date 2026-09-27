#!/bin/bash
MODE="$1"
STATE_FILE="/tmp/wofi-toggle-state"

# Check if a wofi is currently running
WOFI_RUNNING=false
if pgrep -x "wofi" >/dev/null 2>&1; then
    WOFI_RUNNING=true
    pkill -9 -x "wofi" 2>/dev/null
fi

# If a wofi was actually running AND it was the same mode, stop here (toggle off)
if [ -f "$STATE_FILE" ]; then
    CURRENT_MODE=$(cat "$STATE_FILE" 2>/dev/null)
    rm -f "$STATE_FILE"
    if [ "$WOFI_RUNNING" = true ] && [ "$CURRENT_MODE" = "$MODE" ]; then
        exit 0
    fi
fi

case "$MODE" in
    drun) wofi --show drun & ;;
    display) ~/.config/wofi/scripts/selector.sh display & ;;
    capture) ~/.config/wofi/scripts/selector.sh capture & ;;
esac

printf '%s' "$MODE" > "$STATE_FILE"
