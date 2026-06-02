#!/bin/bash
current_ws=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .activeWorkspace.id')

eval "windows=($(hyprctl clients -j | jq -r --argjson ws "$current_ws" '[.[] | select(.workspace.id == $ws and .mapped == true)] | sort_by(.at[1], .at[0]) | .[].address'))"

n=${#windows[@]}
if [ "$n" -lt 2 ]; then
    exit 0
fi

target="${windows[0]}"
for ((i=1; i<n; i++)); do
    hyprctl dispatch focuswindow address:"$target"
    hyprctl dispatch swapwindow address:"${windows[$i]}"
done
