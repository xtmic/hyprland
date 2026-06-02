#!/bin/bash

STATE_FILE="/tmp/hypr-minimize-state-$(id -u)"

clean_stale_state() {
    if [ -f "$STATE_FILE" ]; then
        saved_addr=$(jq -r '.address' "$STATE_FILE")
        if [ "$saved_addr" != "null" ]; then
            local exists
            exists=$(hyprctl clients -j | jq --arg addr "$saved_addr" '[.[] | select(.address == $addr)] | length')
            [ "$exists" -eq 0 ] && rm -f "$STATE_FILE"
        else
            rm -f "$STATE_FILE"
        fi
    fi
}

get_monitor_info() {
    local ws_id=$1
    hyprctl monitors -j | jq -r ".[] | select(.activeWorkspace.id == $ws_id) | {x: .x, y: .y, width: (.width / .scale), height: (.height / .scale)} | @json"
}

clean_stale_state

active=$(hyprctl activewindow -j)
addr=$(echo "$active" | jq -r '.address')
ws=$(echo "$active" | jq -r '.workspace.id')
is_floating=$(echo "$active" | jq -r '.floating')

[ "$addr" = "null" ] && exit 0

# ========== RESTORE ==========
if [ -f "$STATE_FILE" ]; then
    saved_addr=$(jq -r '.address' "$STATE_FILE")
    if [ "$saved_addr" = "$addr" ]; then
        saved_x=$(jq -r '.x' "$STATE_FILE")
        saved_y=$(jq -r '.y' "$STATE_FILE")
        saved_w=$(jq -r '.w' "$STATE_FILE")
        saved_h=$(jq -r '.h' "$STATE_FILE")
        saved_was_floating=$(jq -r '.was_floating' "$STATE_FILE")
        saved_ws=$(jq -r '.workspace' "$STATE_FILE")

        hyprctl dispatch movetoworkspace "$saved_ws,address:$addr"

        if [ "$saved_was_floating" = "true" ]; then
            hyprctl dispatch resizewindowpixel exact "${saved_w} ${saved_h},address:$addr"
        fi
        hyprctl dispatch movewindowpixel exact "${saved_x} ${saved_y},address:$addr"

        if [ "$saved_was_floating" = "false" ]; then
            sleep 0.04
            hyprctl dispatch togglefloating
        fi

        rm -f "$STATE_FILE"
        exit 0
    fi
fi

# ========== MINIMIZE ==========
window_count=$(hyprctl clients -j | jq --arg ws "$ws" '[.[] | select(.workspace.id == ($ws | tonumber) and .monitor != -1)] | length')

[ "$window_count" -ne 1 ] && exit 0

x=$(echo "$active" | jq -r '.at[0]')
y=$(echo "$active" | jq -r '.at[1]')
w=$(echo "$active" | jq -r '.size[0]')
h=$(echo "$active" | jq -r '.size[1]')

monitor_info=$(get_monitor_info "$ws")
mon_y=$(echo "$monitor_info" | jq -r '.y')

hide_y=$(( mon_y - h + 2 ))

hyprctl dispatch movewindowpixel exact "${x} ${hide_y},address:$addr"

echo "{\"address\":\"$addr\",\"x\":$x,\"y\":$y,\"w\":$w,\"h\":$h,\"was_floating\":$is_floating,\"workspace\":$ws}" > "$STATE_FILE"
