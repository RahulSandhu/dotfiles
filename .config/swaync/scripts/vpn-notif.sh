#!/bin/bash

# Kill other instances but not ourselves
for pid in $(pgrep -f "vpn-notif.sh"); do
    [ "$pid" != "$$" ] && kill "$pid" 2>/dev/null
done
sleep 0.2

# Single-instance lock
exec 9>/tmp/vpn_monitor.lock
flock -n 9 || exit 0

ID=9981

# Check if PIA is currently handling the VPN
is_pia_connected() {
    command -v piactl &>/dev/null && [ "$(piactl get connectionstate 2>/dev/null)" = "Connected" ]
}

# Monitor nmcli VPN state changes (any VPN, not a specific one)
monitor_nmcli() {
    local prev_state="unknown"
    local prev_vpn=""

    # Initial state check
    active_vpn=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep ':vpn$' | head -1 | cut -d':' -f1)
    if [ -n "$active_vpn" ]; then
        prev_state="Connected"
        # Skip when PIA is active; its own monitor handles notifications
        if ! is_pia_connected; then
            IP=$(nmcli -g IP4.ADDRESS device show tun0 2>/dev/null | cut -d'/' -f1)
            notify-send \
                --app-name="PIA VPN" \
                --icon=network-vpn \
                --urgency=low \
                --expire-time=5000 \
                --replace-id="$ID" \
                "VPN Connected" "$active_vpn\nIP: ${IP:-Unknown}"
        fi
    else
        prev_state="Disconnected"
    fi

    while true; do
        # Get any active VPN connection by type
        active_vpn=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep ':vpn$' | head -1 | cut -d':' -f1)

        if [ -n "$active_vpn" ]; then
            state="Connected"
        else
            state="Disconnected"
        fi

        if [ "$state" != "$prev_state" ] && [ "$prev_state" != "unknown" ]; then
            # Skip all transitions when PIA is active; monitor_pia handles them
            if ! is_pia_connected; then
                if [ "$state" = "Connected" ]; then
                    IP=$(nmcli -g IP4.ADDRESS device show tun0 2>/dev/null | cut -d'/' -f1)
                    notify-send \
                        --app-name="PIA VPN" \
                        --icon=network-vpn \
                        --urgency=low \
                        --expire-time=5000 \
                        --replace-id="$ID" \
                        "VPN Connected" "$active_vpn\nIP: ${IP:-Unknown}"
                else
                    notify-send \
                        --app-name="PIA VPN" \
                        --icon=network-vpn-disconnected \
                        --urgency=normal \
                        --expire-time=5000 \
                        --replace-id="$ID" \
                        "VPN Disconnected" "Connection is now unsecured"
                fi
            fi
        fi

        prev_state="$state"
        prev_vpn="$active_vpn"
        sleep 2
    done
}

# Monitor PIA if available
monitor_pia() {
    # piactl monitor emits the current state on subscription, then state changes.
    # No initial state check is needed here; the loop below handles everything.
    while read STATUS; do
        if [[ "$STATUS" == "Connecting" ]]; then
            notify-send \
                --app-name="PIA VPN" \
                --icon=network-wireless-acquiring-symbolic \
                --urgency=normal \
                --expire-time=3000 \
                --replace-id="$ID" \
                "VPN Connecting" "Negotiating keys..."

        elif [[ "$STATUS" == "Disconnected" ]]; then
            notify-send \
                --app-name="PIA VPN" \
                --icon=network-vpn-disconnected \
                --urgency=normal \
                --expire-time=5000 \
                --replace-id="$ID" \
                "VPN Disconnected" "Connection is now unsecured"

        elif [[ "$STATUS" == "Connected" ]]; then
            FINAL_IP="Unknown"
            for i in {1..20}; do
                IP=$(piactl get vpnip)
                if [[ "$IP" != "Unknown" && -n "$IP" ]]; then
                    FINAL_IP="$IP"
                    break
                fi
                sleep 0.5
            done

            REGION=$(piactl get region)
            notify-send \
                --app-name="PIA VPN" \
                --icon=network-vpn \
                --urgency=low \
                --expire-time=5000 \
                --replace-id="$ID" \
                "VPN Connected" "Region: $REGION\nIP: $FINAL_IP"
        fi
    done < <(piactl monitor connectionstate)
}

# Run both monitors
if command -v piactl &>/dev/null; then
    monitor_pia &
fi

monitor_nmcli &

wait
