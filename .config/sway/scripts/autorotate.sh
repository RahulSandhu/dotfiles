#!/usr/bin/env bash
# autorotate.sh - rotate the internal panel to follow device orientation.
#
# Intended to run only while the laptop is in tablet mode; sway's bindswitch
# starts it on tablet:on and stops it on tablet:off (see .config/sway/config).
#
# Usage: autorotate.sh {start|stop|status}
set -euo pipefail

OUTPUT="${AUTOROTATE_OUTPUT:-eDP-1}"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
PIDFILE="$RUNTIME_DIR/autorotate.pid"
SELF="$(readlink -f "$0")"

apply() {
    swaymsg output "$OUTPUT" transform "$1" >/dev/null 2>&1 || true
}

# Foreground loop: read orientation changes from iio-sensor-proxy and apply
# the matching transform. bottom-up (180) is intentionally ignored so the
# screen never flips fully upside-down.
run() {
    printf '%s\n' "$$" > "$PIDFILE"
    stdbuf -oL monitor-sensor 2>/dev/null | while IFS= read -r line; do
        case "$line" in
            *orientation*) ;;
            *) continue ;;
        esac
        orient="$(printf '%s' "$line" | grep -oE 'normal|bottom-up|left-up|right-up' | head -n1 || true)"
        [[ -n "$orient" ]] || continue
        case "$orient" in
            normal)    apply normal ;;
            right-up)  apply 90 ;;
            left-up)   apply 270 ;;
            bottom-up) : ;;   # ignore upside-down
        esac
    done
}

start() {
    stop
    rm -f "$PIDFILE"
    setsid "$SELF" run >/dev/null 2>&1 </dev/null &
    # Wait for the daemon to publish its pid before returning.
    for _ in {1..20}; do
        [[ -s "$PIDFILE" ]] && return 0
        sleep 0.05
    done
}

stop() {
    if [[ -s "$PIDFILE" ]]; then
        local pid
        pid="$(cat "$PIDFILE")"
        kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
        sleep 0.2
        kill -KILL -- "-$pid" 2>/dev/null || true
        rm -f "$PIDFILE"
    fi
    apply normal
}

status() {
    if [[ -s "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        echo "autorotate: running (pid $(cat "$PIDFILE"))"
    else
        echo "autorotate: stopped"
    fi
}

case "${1:-}" in
    start)  start ;;
    stop)   stop ;;
    run)    run ;;
    status) status ;;
    *) echo "usage: $0 {start|stop|status}" >&2; exit 2 ;;
esac
