#!/usr/bin/env bash
RECORDING_FILE="$HOME/Видео/recording_$(date +%Y%m%d_%H%M%S).mp4"
SELECTION="${1:-}"

if pgrep -x wf-recorder >/dev/null; then
    pkill -x wf-recorder
    notify-send "Recording saved" "$RECORDING_FILE"
else
    if [ "$SELECTION" = "-g" ]; then
        wf-recorder -g "$(slurp)" -f "$RECORDING_FILE"
    else
        wf-recorder -f "$RECORDING_FILE"
    fi
    notify-send "Recording started" "$RECORDING_FILE"
fi
