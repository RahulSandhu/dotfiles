#!/usr/bin/env bash

wifi_icon="󰖩"
vpn_icon="󰠥"
offline_icon="󰌙"
eth_icon="󰈀"
airplane_icon="󰀝"

# Check VPN status
is_vpn=false
if nmcli connection show --active 2>/dev/null | grep -qi "vpn"; then
    is_vpn=true
elif command -v piactl &>/dev/null && [ "$(piactl get connectionstate 2>/dev/null)" = "Connected" ]; then
    is_vpn=true
fi

# Helper: get current WiFi SSID
get_ssid() {
    local ssid=""
    ssid=$(iwgetid -r 2>/dev/null)
    if [ -n "$ssid" ]; then
        echo "$ssid"
        return 0
    fi
    if command -v nmcli &>/dev/null; then
        ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F': ' '/^yes:/{print $2; exit}')
        if [ -n "$ssid" ]; then
            echo "$ssid"
            return 0
        fi
    fi
    return 1
}

# Determine the default-route interface
default_iface=$(ip route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -1)

# Default route is Ethernet
if [ -n "$default_iface" ] && [ ! -d "/sys/class/net/$default_iface/wireless" ]; then
    if [ "$is_vpn" = true ]; then
        echo "$vpn_icon Ethernet"
    else
        echo "$eth_icon Ethernet"
    fi
    exit 0
fi

# Default route is WiFi
if [ -n "$default_iface" ] && [ -d "/sys/class/net/$default_iface/wireless" ]; then
    ssid=$(get_ssid)
    if [ "$is_vpn" = true ]; then
        echo "$vpn_icon ${ssid:-WiFi}"
    else
        echo "$wifi_icon ${ssid:-WiFi}"
    fi
    exit 0
fi

# No default route: fallback to any active WiFi
ssid=$(get_ssid)
if [ -n "$ssid" ]; then
    if [ "$is_vpn" = true ]; then
        echo "$vpn_icon $ssid"
    else
        echo "$wifi_icon $ssid"
    fi
    exit 0
fi

# No default route, no WiFi: check if we're online somehow
if ! ping -q -c 1 -W 1 8.8.8.8 &>/dev/null; then
    # If both WiFi and WWAN radios are disabled, we're in airplane mode
    if command -v nmcli &>/dev/null; then
        wifi_status=$(nmcli radio wifi 2>/dev/null)
        wwan_status=$(nmcli radio wwan 2>/dev/null)
        if [ "$wifi_status" = "disabled" ] && [ "$wwan_status" = "disabled" ]; then
            echo "$airplane_icon Airplane"
            exit 0
        fi
    fi
    echo "$offline_icon Offline"
    exit 0
fi

# Online but via unknown interface
echo "$eth_icon Ethernet"
