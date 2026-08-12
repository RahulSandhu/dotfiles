#!/bin/bash

# Check PIA
if command -v piactl &>/dev/null; then
    PIA_STATUS=$(piactl get connectionstate)
    if [ "$PIA_STATUS" = "Connected" ]; then
        echo "true"
        exit 0
    fi
fi

# Check any nmcli VPN (by connection type, not name)
if nmcli -t -f TYPE connection show --active 2>/dev/null | grep -q '^vpn$'; then
    echo "true"
    exit 0
fi

echo "false"
