#!/bin/bash

# Check PIA status
pia_connected=false
if command -v piactl &>/dev/null; then
    PIA_STATUS=$(piactl get connectionstate)
    [ "$PIA_STATUS" = "Connected" ] && pia_connected=true
fi

# Check any nmcli VPN status
nmcli_vpn=""
nmcli_connected=false
active_vpn=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep ':vpn$' | head -1 | cut -d':' -f1)
if [ -n "$active_vpn" ]; then
    nmcli_connected=true
    nmcli_vpn="$active_vpn"
fi

# Toggle logic
if $pia_connected; then
    piactl disconnect
elif $nmcli_connected; then
    nmcli connection down "$nmcli_vpn"
else
    # Default: connect PIA (change to nmcli connection up "YourVPN" if preferred)
    piactl connect
fi
