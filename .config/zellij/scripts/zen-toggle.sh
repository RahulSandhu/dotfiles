#!/usr/bin/env bash

SESSION_NAME="zen"
TITLE="zen-workspace"
LAUNCHER="$HOME/.config/zellij/scripts/zen.sh"

# No-op if already inside any zellij session
[[ -n "$ZELLIJ" ]] && exit 0

# Find an existing zen-workspace Kitty window (exclude this script itself)
ZEN_PID=$(pgrep -af "kitty.*--title $TITLE" | grep -v "$$" | awk '{print $1}' | head -n1)

if [ -n "$ZEN_PID" ]; then
    # Window is visible: close it. The zellij session stays alive in the background.
    kill "$ZEN_PID"
    exit 0
fi

# No existing window: open a new Kitty window running the launcher
kitty --title "$TITLE" --directory "$HOME" bash "$LAUNCHER"
