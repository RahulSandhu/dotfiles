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

# Tunnels opened outside NetworkManager (a manual `openvpn --config ...`, for
# instance) only show up as a plain tun/tap link. Skip Tailscale's own device,
# and skip tunnels that a NetworkManager VPN connection already reports.
tun_interfaces() {
    local dev nmvpn
    nmvpn=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null \
        | awk -F: '$2=="vpn"{print $3}')
    for dev in $(ip -o link show type tun 2>/dev/null | awk -F': ' '{print $2}' | cut -d@ -f1); do
        case "$dev" in tailscale*) continue ;; esac
        printf '%s\n' "$nmvpn" | grep -qx "$dev" && continue
        echo "$dev"
    done
}

active_set() {
    tailscale_is_up && echo "Tailscale"
    local i n
    for i in $(wg_interfaces); do echo "WireGuard:$i"; done
    for n in $(nm_vpn_connections); do echo "VPN:$n"; done
    for i in $(tun_interfaces); do echo "Tunnel:$i"; done
}

first_active() {
    active_set | head -1
}

set_string() {
    sort -u | paste -sd, -
}

split_set() {
    printf '%s\n' "$1" | tr ',' '\n' | grep -v '^$' | sort -u
}

# set_diff 13 <old> <new> -> tunnels that appeared; 23 -> tunnels that went away
set_diff() {
    comm -"$1" <(split_set "$2") <(split_set "$3")
}

tailnet_state() {
    split_set "$1" | grep -qx Tailscale && echo Tailscale
}

tunnel_detail() {
    case "$1" in
        Tailscale)   tailscale ip -4 2>/dev/null | head -1 ;;
        VPN:*)       nmcli -g IP4.ADDRESS connection show "${1#VPN:}" 2>/dev/null | head -1 | cut -d/ -f1 ;;
        WireGuard:*) ip -4 -o addr show "${1#WireGuard:}" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1 ;;
        Tunnel:*)    ip -4 -o addr show "${1#Tunnel:}" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1 ;;
    esac
}

notify_connecting() {
    notify-send --app-name="VPN" --icon=network-wireless-acquiring-symbolic \
        --urgency=normal --replace-id="$ID" \
        "VPN Connecting" "Bringing up Tailscale..."
}

label_text() {
    case "$1" in
        Tailscale)   echo "Tailscale" ;;
        WireGuard:*) echo "WireGuard (${1#WireGuard:})" ;;
        VPN:*)       echo "VPN \"${1#VPN:}\"" ;;
        Tunnel:*)    echo "OpenVPN (${1#Tunnel:})" ;;
        *)           echo "$1" ;;
    esac
}

notify_connected() {
    local ip title="VPN Connected"
    ip=$(tunnel_detail "$1")
    [ "$1" = "Tailscale" ] && title="Tailnet Connected"
    notify-send --app-name="VPN" --icon=network-vpn --urgency=low \
        --replace-id="$ID" "$title" "$(label_text "$1")${ip:+ · $ip}"
}

notify_disconnected() {
    notify-send --app-name="VPN" --icon=network-vpn-disconnected-symbolic \
        --urgency=normal --replace-id="$ID" \
        "VPN Disconnected" "Disconnected from $(label_text "$1")"
}

# A hand-started OpenVPN client (`sudo openvpn --config ... --daemon`) is not
# owned by NetworkManager, so `nmcli connection down` leaves it running. It also
# runs as root, which is why the SIGTERM has to go through sudo. TERM lets the
# client delete its routes and tun device itself; SIGKILL is only a last resort
# because it leaves those behind.
stop_openvpn() {
    pgrep -x openvpn >/dev/null 2>&1 || return 0

    # Try unprivileged first (a client started with --user owns its process),
    # then fall back to passwordless sudo (a client started with plain `sudo`).
    pkill -x openvpn >/dev/null 2>&1
    sudo -n pkill -x openvpn >/dev/null 2>&1
    local i
    for i in {1..10}; do
        pgrep -x openvpn >/dev/null 2>&1 || return 0
        sleep 0.2
    done

    pkill -9 -x openvpn >/dev/null 2>&1
    sudo -n pkill -9 -x openvpn >/dev/null 2>&1
    pgrep -x openvpn >/dev/null 2>&1 || return 0

    notify-send --app-name="VPN" --icon=dialog-error --urgency=normal \
        --replace-id="$ID" "VPN Disconnect Failed" \
        "OpenVPN runs as root. Allow it with: sudo pkill -x openvpn"
    return 1
}

disconnect_all() {
    tailscale_is_up && tailscale down >/dev/null 2>&1
    local n i
    for n in $(nm_vpn_connections); do nmcli connection down "$n" >/dev/null 2>&1; done
    for i in $(wg_interfaces); do sudo -n wg-quick down "$i" >/dev/null 2>&1 || true; done
    stop_openvpn
}

# Follow the tailnet state for the homelab mounts: mount ~/music and
# ~/public/homelab when Tailscale is connected, unmount otherwise. The actual
# mounts are done by ~/.config/rclone/scripts/rclone-mount.sh.
homelab_mounts_follow_vpn() {
    local target
    for target in music backup; do
        # 9>&- : never let the children inherit the monitor's flock fd, or a
        # long-lived rclone would keep /tmp/vpn-monitor.lock held forever.
        case "$1" in
            Tailscale) "$HOME/.config/rclone/scripts/rclone-mount.sh" "$target" mount >/dev/null 2>&1 9>&- & ;;
            *)         "$HOME/.config/rclone/scripts/rclone-mount.sh" "$target" unmount >/dev/null 2>&1 9>&- ;;
        esac
    done
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

    # Track the whole set of tunnels, not just the first one: with Tailscale
    # already up, a second tunnel would otherwise never change the state.
    local prev; prev=$(active_set | set_string)
    local cur added removed

    # announce the starting state once (retry until the notification daemon is up)
    local first; first=$(split_set "$prev" | head -1)
    if [ -n "$first" ]; then
        local i
        for i in {1..10}; do
            notify_connected "$first" && break
            sleep 0.5
        done
    fi

    # bring the homelab mounts in line with the current tailnet state
    homelab_mounts_follow_vpn "$(tailnet_state "$prev")"

    while true; do
        cur=$(active_set | set_string)
        if [ "$cur" != "$prev" ]; then
            added=$(set_diff 13 "$prev" "$cur")
            removed=$(set_diff 23 "$prev" "$cur")
            [ -n "$added" ] && notify_connected "$(printf '%s\n' "$added" | head -1)"
            [ -n "$removed" ] && notify_disconnected "$(printf '%s\n' "$removed" | head -1)"
            prev="$cur"
            homelab_mounts_follow_vpn "$(tailnet_state "$cur")"
        fi
        sleep 2
    done
}

if [ "$1" = "--monitor" ]; then
    monitor_mode
elif [ "$1" = "--status" ]; then
    # Same detection the toggle uses, so button state and click action can never
    # disagree. Plain `ip link show type tun` is not enough: tailscale0 is a tun
    # device too and would keep the button lit while Tailscale is stopped.
    if [ -n "$(first_active)" ]; then echo true; else echo false; fi
else
    toggle
fi
