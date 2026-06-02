#!/bin/bash

active=$(hyprctl activewindow -j)
active_addr=$(echo "$active" | jq -r '.address')
active_w=$(echo "$active" | jq -r '.size[0]')
active_h=$(echo "$active" | jq -r '.size[1]')
active_ws=$(echo "$active" | jq -r '.workspace.id')

[ "$active_w" = "null" ] || [ -z "$active_w" ] && exit 1

hyprctl clients -j | jq -c '.[]' | while read -r win; do
    addr=$(echo "$win" | jq -r '.address')
    ws=$(echo "$win" | jq -r '.workspace.id')
    mapped=$(echo "$win" | jq -r '.mapped')
    fullscreen=$(echo "$win" | jq -r '.fullscreen')

    if [ "$addr" != "$active_addr" ] && \
       [ "$ws" = "$active_ws" ] && \
       [ "$mapped" = "true" ] && \
       [ "$fullscreen" = "0" ]; then
        hyprctl dispatch resizewindowpixel exact "$active_w" "$active_h", address:"$addr"
    fi
done
