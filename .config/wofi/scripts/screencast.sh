#!/bin/bash

# Define the path for the screencast PID
PID_FILE="/tmp/wl_screencast.pid"

# Audio source (system audio monitor)
AUDIO_SOURCE="alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"

# Stream directory
STREAM_DIR="/tmp/stream"

# Get local IP
LOCAL_IP=$(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)

# Check if a screencast is already in progress
if [ -f "$PID_FILE" ]; then
    # Stop screencast
    read -r WF_PID FFMPEG_PID SERVER_PID < "$PID_FILE"
    kill "$WF_PID" "$FFMPEG_PID" "$SERVER_PID" 2>/dev/null
    rm "$PID_FILE"
    rm -rf "$STREAM_DIR"
    notify-send \
        --app-name="Sway" \
        --icon=preferences-desktop-remote-desktop \
        --urgency=normal \
        --expire-time=5000 \
        "Streaming Stopped" "Stream ended"
    exit 0
fi

# Check for a valid argument first
if [[ "$1" != "full" && "$1" != "area" ]]; then
    echo "Usage: $0 {full|area}"
    echo "(Run without argument to stop an existing screencast)"
    exit 1
fi

# Create stream directory
mkdir -p "$STREAM_DIR"
cd "$STREAM_DIR"

# Start HTTP server in background
python -m http.server 8080 > /dev/null 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 0.5

# Start screencast based on argument
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

# Save PIDs to PID file
echo "$WF_PID $FFMPEG_PID $SERVER_PID" > "$PID_FILE"

notify-send \
    --app-name="Sway" \
    --icon=preferences-desktop-remote-desktop \
    --urgency=low \
    --expire-time=3000 \
    "Streaming Started" "Connect to: http://${LOCAL_IP}:8080/stream.m3u8"
