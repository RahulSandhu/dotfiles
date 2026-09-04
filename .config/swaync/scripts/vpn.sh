#!/bin/bash

ID=9981

is_pia_connected() {
    command -v piactl &>/dev/null && [ "$(piactl get connectionstate 2>/dev/null)" = "Connected" ]
}

notify_connected() {
    local message=$1
    notify-send \
        --app-name="PIA VPN" \
        --icon=network-vpn \
        --urgency=low \
        --expire-time=5000 \
        --replace-id="$ID" \
        "VPN Connected" "$message"
}

notify_disconnected() {
    notify-send \
        --app-name="PIA VPN" \
        --icon=network-vpn-disconnected-symbolic \
        --urgency=normal \
        --expire-time=5000 \
        --replace-id="$ID" \
        "VPN Disconnected" "Connection is now unsecured"
}

notify_connecting() {
    notify-send \
        --app-name="PIA VPN" \
        --icon=network-wireless-acquiring-symbolic \
        --urgency=normal \
        --expire-time=3000 \
        --replace-id="$ID" \
        "VPN Connecting" "Negotiating keys..."
}

# Get the active nmcli VPN name
get_nmcli_vpn() {
    nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep ':vpn$' | head -1 | cut -d':' -f1
}

# Toggle mode (called by swaync button)
toggle() {
    if is_pia_connected; then
        piactl disconnect
    else
        local active_vpn
        active_vpn=$(get_nmcli_vpn)
        if [ -n "$active_vpn" ]; then
            nmcli connection down "$active_vpn"
        else
            piactl connect
        fi
    fi
}

# Monitor PIA state via piactl monitor
monitor_pia() {
    while read -r STATUS; do
        case "$STATUS" in
            Connecting)
                notify_connecting
                ;;
            Disconnected)
                notify_disconnected
                ;;
            Connected)
                local FINAL_IP="Unknown"
                for _ in {1..20}; do
                    local IP
                    IP=$(piactl get vpnip)
                    if [[ "$IP" != "Unknown" && -n "$IP" ]]; then
                        FINAL_IP="$IP"
                        break
                    fi
                    sleep 0.5
                done

                local REGION
                REGION=$(piactl get region)
                notify_connected "Region: $REGION\nIP: $FINAL_IP"
                ;;
        esac
    done < <(piactl monitor connectionstate)
}

# Monitor generic nmcli VPN state changes
monitor_nmcli() {
    local prev_state="unknown"
    local active_vpn

    active_vpn=$(get_nmcli_vpn)
    if [ -n "$active_vpn" ]; then
        prev_state="Connected"
        if ! is_pia_connected; then
            local IP
            IP=$(nmcli -g IP4.ADDRESS device show tun0 2>/dev/null | cut -d'/' -f1)
            notify_connected "$active_vpn\nIP: ${IP:-Unknown}"
        fi
    else
        prev_state="Disconnected"
    fi

    while true; do
        active_vpn=$(get_nmcli_vpn)
        if [ -n "$active_vpn" ]; then
            local state="Connected"
        else
            local state="Disconnected"
        fi

        if [ "$state" != "$prev_state" ] && [ "$prev_state" != "unknown" ]; then
            if ! is_pia_connected; then
                if [ "$state" = "Connected" ]; then
                    local IP
                    IP=$(nmcli -g IP4.ADDRESS device show tun0 2>/dev/null | cut -d'/' -f1)
                    notify_connected "$active_vpn\nIP: ${IP:-Unknown}"
                else
                    notify_disconnected
                fi
            fi
        fi

        prev_state="$state"
        sleep 2
    done
}

# Run as monitor daemon
monitor_mode() {
    # Single-instance lock
    exec 9>/tmp/vpn-monitor.lock
    flock -n 9 || exit 0

    if command -v piactl &>/dev/null; then
        monitor_pia &
    fi

    monitor_nmcli &

    wait
}

# Main entrypoint
if [ "$1" = "--monitor" ]; then
    monitor_mode
else
    toggle
fi
