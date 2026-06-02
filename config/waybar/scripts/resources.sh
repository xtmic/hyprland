#!/bin/bash

STATE_FILE="/tmp/waybar-resources-state"

if [ "$1" = "--toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        CURRENT=$(cat "$STATE_FILE")
        if [ "$CURRENT" = "collapsed" ]; then
            echo "expanded" > "$STATE_FILE"
        else
            echo "collapsed" > "$STATE_FILE"
        fi
    else
        echo "expanded" > "$STATE_FILE"
    fi
    exit 0
fi

if [ ! -f "$STATE_FILE" ]; then
    echo "collapsed" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d, -f1)
[ -z "$CPU" ] && CPU=$(top -bn1 | grep "%Cpu" | awk '{print $2}' | cut -d, -f1)
[ -z "$CPU" ] && CPU=0

MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
MEM_PCT=$(free -m | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')

DISK_PCT=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_AVAIL=$(df -h / | awk 'NR==2 {print $4}')

TEMP=$(sensors 2>/dev/null | grep -i "core 0" | awk '{print $3}' | tr -d '+°C' | cut -d. -f1)
[ -z "$TEMP" ] && TEMP="N/A"

GPU_PCT=$(cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)
[ -z "$GPU_PCT" ] && GPU_PCT="N/A"

if [ "$STATE" = "expanded" ]; then
    TEXT="󰻠 ${CPU}% 󰘚${MEM_PCT}% ${DISK_PCT}%"
    CLASS="resources expanded"
else
    TEXT="󰻠"
    CLASS="resources collapsed"
fi

TOOLTIP="CPU: ${CPU}%\nRAM: ${MEM_USED}M / ${MEM_TOTAL}M (${MEM_PCT}%)\n\uf0a0 ${DISK_USED} / ${DISK_AVAIL} (${DISK_PCT}%)\n\uf2c9 ${TEMP}°C\n\ue627 GPU ${GPU_PCT}%"

printf '{"text": "%s", "tooltip": "%s", "class": "%s", "alt": "%s"}\n' \
    "$TEXT" "$TOOLTIP" "$CLASS" "$STATE"
