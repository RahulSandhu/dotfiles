#!/bin/bash

ID=9993

wifi_device() {
    nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2=="wifi" {print $1; exit}'
}

active_ssid() {
    nmcli -t -f active,ssid dev wifi list 2>/dev/null | grep '^yes:' | head -n1 | cut -d: -f2
}

wifi_ip() {
    local dev="$1"
    [ -n "$dev" ] || return 0
    nmcli -g IP4.ADDRESS device show "$dev" 2>/dev/null | head -n1 | cut -d'/' -f1
}

notify_connected() {
    notify-send \
        --app-name="Sway" \
        --icon=network-wireless-connected-symbolic \
        --urgency=low \
        --expire-time=3000 \
        --replace-id="$ID" \
        "Wi-Fi Connected" "SSID: ${1:-Unknown}\nIP: ${2:-Unknown}"
}

notify_disconnected() {
    notify-send \
        --app-name="Sway" \
        --icon=network-wireless-disabled-symbolic \
        --urgency=low \
        --expire-time=3000 \
        --replace-id="$ID" \
        "Wi-Fi Disconnected" "Disconnected from ${1:-Unknown}"
}

toggle() {
    WIFI_IDX=$(rfkill | grep -i wlan | awk '{print $1}' | head -n 1)

    if rfkill list "$WIFI_IDX" | grep -q "Soft blocked: yes"; then
        rfkill unblock "$WIFI_IDX"

        SSID=""
        for _ in {1..20}; do
            SSID=$(active_ssid)
            [[ -n "$SSID" ]] && break
            sleep 0.5
        done

        IP=$(wifi_ip "$(wifi_device)")

        notify-send \
            --app-name="Sway" \
            --icon=network-wireless-connected-symbolic \
            --urgency=low \
            --expire-time=3000 \
            --replace-id=9993 \
            "Wi-Fi Connected" "SSID: ${SSID:-Unknown}\nIP: ${IP:-Unknown}"
    else
        rfkill block "$WIFI_IDX"
        notify-send \
            --app-name="Sway" \
            --icon=network-wireless-disabled-symbolic \
            --urgency=low \
            --expire-time=3000 \
            --replace-id=9993 \
            "Wi-Fi Disconnected" "Off"
    fi
}

# React to NetworkManager connect/disconnect events (including manual nmcli
# commands). Silent until the first transition after launch.
monitor_mode() {
    exec 9>/tmp/wifi-monitor.lock
    flock -n 9 || exit 0

    local prev_ssid; prev_ssid=$(active_ssid)

    while true; do
        local cur_ssid; cur_ssid=$(active_ssid)
        if [ "$cur_ssid" != "$prev_ssid" ]; then
            if [ -n "$cur_ssid" ]; then
                notify_connected "$cur_ssid" "$(wifi_ip "$(wifi_device)")"
            else
                notify_disconnected "$prev_ssid"
            fi
            prev_ssid="$cur_ssid"
        fi
        sleep 2
    done
}

if [ "$1" = "--monitor" ]; then
    monitor_mode
else
    toggle
fi
