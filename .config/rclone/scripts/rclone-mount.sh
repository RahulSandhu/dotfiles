#!/bin/bash

# Mount/unmount a homelab share inside $HOME.
# Pure mount logic: whether to mount is decided by the caller (the VPN monitor
# in ~/.config/swaync/scripts/vpn.sh), which mounts when Tailscale is connected
# and unmounts otherwise.
# Usage: rclone-mount.sh {music|backup} {mount|unmount}

CONFIG="${HOME}/.config/rclone/rclone.conf"

# Tailscale reports "Running" as soon as the tailnet is up, but MagicDNS (and
# with it the homelab SSH endpoint) can take several more seconds to become
# usable. Keep retrying until the mount actually comes up, giving up after WAIT
# seconds. Overridable for testing.
WAIT="${RCLONE_MOUNT_WAIT:-60}"

TARGET="${1:-}"
ACTION="${2:-}"

case "$TARGET" in
    music)
        MOUNT="${HOME}/music"
        REMOTE="homelab:/srv/music"
        NAME="Music"
        NOTIFY_ID=9986
        OPTS=(--vfs-cache-mode writes)
        DIR_CACHE=1m
        ;;
    backup)
        MOUNT="${HOME}/public/homelab"
        REMOTE="homelab:/srv/backup"
        NAME="Backup"
        NOTIFY_ID=9987
        # Read-only: the mirror must never be written to.
        OPTS=(--read-only --vfs-cache-mode off)
        DIR_CACHE=10m
        ;;
    *)
        echo "usage: $0 {music|backup} {mount|unmount}" >&2
        exit 2
        ;;
esac

LOG="${HOME}/.cache/rclone-${TARGET}.log"
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/rclone-${TARGET}-mount.pid"

case "$MOUNT" in
    "$HOME"/*) DISPLAY_MOUNT="~${MOUNT#"$HOME"}" ;;
    *)         DISPLAY_MOUNT="$MOUNT" ;;
esac

notify_mounted() {
    notify-send \
        --app-name="rclone" \
        --icon=folder-remote \
        --urgency=low \
        --replace-id="$NOTIFY_ID" \
        "${NAME} Mounted" "${REMOTE} is available at ${DISPLAY_MOUNT}" \
        >/dev/null 2>&1 || true
}

notify_failed() {
    notify-send \
        --app-name="rclone" \
        --icon=dialog-error \
        --urgency=critical \
        --replace-id="$NOTIFY_ID" \
        "${NAME} Mount Failed" "Could not mount ${REMOTE} at ${DISPLAY_MOUNT}; see ${LOG}" \
        >/dev/null 2>&1 || true
}

mount_target() {
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
                "${OPTS[@]}" \
                --dir-cache-time "$DIR_CACHE" \
                --vfs-cache-max-age 24h \
                --log-level NOTICE \
                --log-file "$LOG" \
                >/dev/null 2>&1 &
            pid=$!
        fi

        # Give the attempt a few seconds to establish the mount point.
        for _ in 1 2 3 4 5; do
            if mountpoint -q "$MOUNT"; then
                notify_mounted
                # The music library just appeared; tell mpd to re-index it.
                [ "$TARGET" = music ] && { rmpc update >/dev/null 2>&1 || true; }
                exit 0
            fi
            sleep 1
        done

        if [ "$(date +%s)" -ge "$deadline" ]; then
            notify_failed
            exit 1
        fi
    done
}

unmount_target() {
    # Cancel any in-flight mount attempt so it can't re-mount after we unmount.
    if [ -f "$PIDFILE" ]; then
        kill "$(cat "$PIDFILE")" 2>/dev/null || true
        rm -f "$PIDFILE"
    fi
    fusermount3 -uz "$MOUNT" 2>/dev/null || true
}

case "$ACTION" in
    mount)   mount_target ;;
    unmount) unmount_target ;;
    *)
        echo "usage: $0 {music|backup} {mount|unmount}" >&2
        exit 2
        ;;
esac
