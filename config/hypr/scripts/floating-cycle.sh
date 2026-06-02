#!/bin/bash
STATE_FILE="/tmp/hypr-floating-cycle"

current_ws=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

mapfile -t windows < <(hyprctl clients -j | jq -r --argjson ws "$current_ws" '[.[] | select(.workspace.id == $ws and .mapped == true)] | sort_by(.address) | .[].address')

num_windows=${#windows[@]}

if [ "$num_windows" -eq 0 ]; then
    exit 0
fi

idx=0
if [ -f "$STATE_FILE" ]; then
    saved=$(cat "$STATE_FILE")
    if [[ "$saved" =~ ^[0-9]+$ ]]; then
        idx=$(( (saved + 1) % num_windows ))
    fi
fi

echo "$idx" > "$STATE_FILE"

hyprctl dispatch togglefloating address:${windows[$idx]}
