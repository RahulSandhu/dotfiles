#!/bin/bash

if command -v tailscale >/dev/null 2>&1; then
    state=$(tailscale status --json 2>/dev/null | tr -d ' \n' \
        | grep -o '"BackendState":"[^"]*"' | head -1 | cut -d'"' -f4)
    [ "$state" = "Running" ] && { echo true; exit 0; }
fi

ip -o link show type wireguard 2>/dev/null | grep -q . && { echo true; exit 0; }

nmcli -t -f TYPE connection show --active 2>/dev/null | grep -qE '^(vpn|wireguard)$' && { echo true; exit 0; }

echo false
