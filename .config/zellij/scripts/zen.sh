#!/usr/bin/env bash

SESSION_NAME="zen"
LAYOUT_FILE="$HOME/.config/zellij/layouts/zen.kdl"

# No-op if already inside any zellij session
[[ -n "$ZELLIJ" ]] && exit 0

if zellij list-sessions --short 2>/dev/null | grep -q "^$SESSION_NAME$"; then
    # Session exists: attach to it
    zellij attach "$SESSION_NAME"
else
    # No active session: delete any serialized state and create fresh
    zellij delete-session "$SESSION_NAME" --force 2>/dev/null
    zellij --session "$SESSION_NAME" --new-session-with-layout "$LAYOUT_FILE"
fi
