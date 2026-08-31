#!/bin/bash

WIFI_IDX=$(rfkill | grep -i wlan | awk '{print $1}' | head -n 1)

if rfkill list "$WIFI_IDX" | grep -q "Soft blocked: yes"; then
    rfkill unblock "$WIFI_IDX"

    SSID=""
    for _ in {1..20}; do
        SSID=$(nmcli -t -f active,ssid dev wifi list 2>/dev/null | grep '^yes:' | head -n1 | cut -d: -f2)
        [[ -n "$SSID" ]] && break
        sleep 0.5
    done

    WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2=="wifi" {print $1; exit}')
    if [[ -n "$WIFI_DEV" ]]; then
        IP=$(nmcli -g IP4.ADDRESS device show "$WIFI_DEV" 2>/dev/null | head -n1 | cut -d'/' -f1)
    fi

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