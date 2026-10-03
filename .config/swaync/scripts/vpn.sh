#!/bin/bash

ID=9981

tailscale_is_up() {
    command -v tailscale >/dev/null 2>&1 || return 1
    local state
    state=$(tailscale status --json 2>/dev/null | tr -d ' \n' \
        | grep -o '"BackendState":"[^"]*"' | head -1 | cut -d'"' -f4)
    [ "$state" = "Running" ]
}

wg_interfaces() {
    ip -o link show type wireguard 2>/dev/null | awk -F': ' '{print $2}' | cut -d@ -f1
}

nm_vpn_connections() {
    nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep -E ':(vpn|wireguard)$' | cut -d: -f1
}

first_active() {
    tailscale_is_up && echo "Tailscale"
    local i n
    for i in $(wg_interfaces); do echo "WireGuard:$i"; done
    for n in $(nm_vpn_connections); do echo "VPN:$n"; done
}

tunnel_detail() {
    case "$1" in
        Tailscale)   tailscale ip -4 2>/dev/null | head -1 ;;
        VPN:*)       nmcli -g IP4.ADDRESS connection show "${1#VPN:}" 2>/dev/null | head -1 | cut -d/ -f1 ;;
        WireGuard:*) ip -4 -o addr show "${1#WireGuard:}" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1 ;;
    esac
}

notify_connecting() {
    notify-send --app-name="VPN" --icon=network-wireless-acquiring-symbolic \
        --urgency=normal --expire-time=3000 --replace-id="$ID" \
        "VPN Connecting" "Bringing up Tailscale..."
}

label_text() {
    case "$1" in
        Tailscale)   echo "Tailscale" ;;
        WireGuard:*) echo "WireGuard (${1#WireGuard:})" ;;
        VPN:*)       echo "VPN \"${1#VPN:}\"" ;;
        *)           echo "$1" ;;
    esac
}

notify_connected() {
    local ip title="VPN Connected"
    ip=$(tunnel_detail "$1")
    [ "$1" = "Tailscale" ] && title="Tailnet Connected"
    notify-send --app-name="VPN" --icon=network-vpn --urgency=low \
        --expire-time=5000 --replace-id="$ID" "$title" "$(label_text "$1")${ip:+ · $ip}"
}

notify_disconnected() {
    notify-send --app-name="VPN" --icon=network-vpn-disconnected-symbolic \
        --urgency=normal --expire-time=5000 --replace-id="$ID" \
        "VPN Disconnected" "Disconnected from $(label_text "$1")"
}

disconnect_all() {
    tailscale_is_up && tailscale down >/dev/null 2>&1
    local n i
    for n in $(nm_vpn_connections); do nmcli connection down "$n" >/dev/null 2>&1; done
    for i in $(wg_interfaces); do sudo -n wg-quick down "$i" >/dev/null 2>&1 || true; done
}

# something is up -> disconnect it, otherwise bring Tailscale up
toggle() {
    if [ -n "$(first_active)" ]; then
        disconnect_all
    else
        notify_connecting
        tailscale up >/dev/null 2>&1
    fi
}

monitor_mode() {
    exec 9>/tmp/vpn-monitor.lock
    flock -n 9 || exit 0

    local prev; prev=$(first_active)

    # announce the starting state once (retry until the notification daemon is up)
    if [ -n "$prev" ]; then
        local i
        for i in {1..10}; do
            notify_connected "$prev" && break
            sleep 0.5
        done
    fi

    while true; do
        local cur; cur=$(first_active)
        if [ "$cur" != "$prev" ]; then
            if [ -n "$cur" ]; then notify_connected "$cur"
            else notify_disconnected "$prev"; fi
            prev="$cur"
        fi
        sleep 2
    done
}

if [ "$1" = "--monitor" ]; then
    monitor_mode
else
    toggle
fi
