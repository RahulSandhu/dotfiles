#!/bin/bash

PID_FILE="/tmp/wl_screencast.pid"
AUDIO_SOURCE="alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"
STREAM_DIR="/tmp/stream"
LOCAL_IP=$(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)

if [ -f "$PID_FILE" ]; then
    read -r WF_PID FFMPEG_PID SERVER_PID < "$PID_FILE"
    kill "$WF_PID" "$FFMPEG_PID" "$SERVER_PID" 2>/dev/null
    rm "$PID_FILE"
    rm -rf "$STREAM_DIR"
    notify-send \
        --app-name="Sway" \
        --icon=preferences-desktop-remote-desktop \
        --urgency=normal \
        "Streaming Stopped" "Stream ended"
    exit 0
fi

if [[ "$1" != "full" && "$1" != "area" ]]; then
    echo "Usage: $0 {full|area}"
    echo "(Run without argument to stop an existing screencast)"
    exit 1
fi

mkdir -p "$STREAM_DIR"
cd "$STREAM_DIR"

python -m http.server 8080 > /dev/null 2>&1 &
SERVER_PID=$!

sleep 0.5

case "$1" in
    full)
        wf-recorder --muxer=mpegts --codec=libx264 --audio --audio-device "$AUDIO_SOURCE" -f pipe:1 2>/dev/null | \
        ffmpeg -i pipe:0 -c:v copy -c:a aac -b:a 128k \
        -f hls -hls_time 1 -hls_list_size 3 \
        -hls_flags delete_segments stream.m3u8 > /dev/null 2>&1 &
        ;;
    area)
        wf-recorder --muxer=mpegts --codec=libx264 --audio --audio-device "$AUDIO_SOURCE" -g "$(slurp)" -f pipe:1 2>/dev/null | \
        ffmpeg -i pipe:0 -c:v copy -c:a aac -b:a 128k \
        -f hls -hls_time 1 -hls_list_size 3 \
        -hls_flags delete_segments stream.m3u8 > /dev/null 2>&1 &
        ;;
esac

FFMPEG_PID=$!
WF_PID=$(pgrep -P $FFMPEG_PID wf-recorder)

echo "$WF_PID $FFMPEG_PID $SERVER_PID" > "$PID_FILE"

notify-send \
    --app-name="Sway" \
    --icon=preferences-desktop-remote-desktop \
    --urgency=low \
    "Streaming Started" "Connect to: http://${LOCAL_IP}:8080/stream.m3u8"
