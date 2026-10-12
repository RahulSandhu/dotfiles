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
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/rclone-music-mount.pid"

# Tailscale reports "Running" as soon as the tailnet is up, but MagicDNS (and
# with it the homelab SSH endpoint) can take several more seconds to become
# usable. Keep retrying until the mount actually comes up, giving up after WAIT
# seconds. Overridable for testing.
WAIT="${RCLONE_MUSIC_WAIT:-60}"

mount_music() {
    mountpoint -q "$MOUNT" && exit 0
    mkdir -p "$MOUNT"

    # Let `unmount` cancel a still-pending mount attempt.
    echo $$ >"$PIDFILE"
    trap 'rm -f "$PIDFILE"' EXIT

    local pid="" deadline=$(( $(date +%s) + WAIT ))
    while :; do
        # Start an attempt unless the previous one is still starting up, so two
        # rclone mounts never race onto the same directory.
        if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
            nohup rclone mount "$REMOTE" "$MOUNT" \
                --config "$CONFIG" \
                --vfs-cache-mode writes \
                --dir-cache-time 1m \
                --vfs-cache-max-age 24h \
                --log-level NOTICE \
                --log-file "$LOG" \
                >/dev/null 2>&1 &
            pid=$!
        fi

        # Give the attempt a few seconds to establish the mount point.
        for _ in 1 2 3 4 5; do
            mountpoint -q "$MOUNT" && exit 0
            sleep 1
        done

        [ "$(date +%s)" -ge "$deadline" ] && exit 1
    done
}

unmount_music() {
    # Cancel any in-flight mount attempt so it can't re-mount after we unmount.
    if [ -f "$PIDFILE" ]; then
        kill "$(cat "$PIDFILE")" 2>/dev/null || true
        rm -f "$PIDFILE"
    fi
    fusermount3 -uz "$MOUNT" 2>/dev/null || true
}

case "${1:-}" in
    mount)   mount_music ;;
    unmount) unmount_music ;;
    *)
        echo "usage: $0 {mount|unmount}" >&2
        exit 2
        ;;
esac
