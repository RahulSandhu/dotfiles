#!/bin/bash

# Mount/unmount the homelab music library at ~/music.
# Pure mount logic: whether to mount is decided by the caller (the VPN monitor
# in ~/.config/swaync/scripts/vpn.sh), which mounts when Tailscale is connected
# and unmounts otherwise.
# Usage: rclone-music.sh {mount|unmount}

MOUNT="${HOME}/music"
REMOTE="homelab:/srv/music"
CONFIG="${HOME}/.config/rclone/rclone.conf"
LOG="${HOME}/.cache/rclone-music.log"

case "${1:-}" in
    mount)
        mountpoint -q "$MOUNT" && exit 0
        mkdir -p "$MOUNT"
        # Brief retry: the tunnel can take a moment to become usable right after
        # the VPN monitor reports it as connected.
        for _ in 1 2 3 4 5; do
            nohup rclone mount "$REMOTE" "$MOUNT" \
                --config "$CONFIG" \
                --vfs-cache-mode writes \
                --dir-cache-time 1m \
                --vfs-cache-max-age 24h \
                --log-level NOTICE \
                --log-file "$LOG" \
                >/dev/null 2>&1 &
            sleep 1
            mountpoint -q "$MOUNT" && exit 0
        done
        exit 1
        ;;
    unmount)
        fusermount3 -uz "$MOUNT" 2>/dev/null || true
        ;;
    *)
        echo "usage: $0 {mount|unmount}" >&2
        exit 2
        ;;
esac
