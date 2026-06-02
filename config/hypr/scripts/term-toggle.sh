#!/bin/bash
CLASS="bottomterm"

if ! hyprctl clients -j | jq -e ".[] | select(.class == \"$CLASS\")" > /dev/null 2>&1; then
    hyprctl dispatch workspace special:term
    sleep 0.1
    kitty --class "$CLASS" -e ~/.config/hypr/scripts/bottomterm.sh &
    sleep 0.3
    hyprctl setprop "class:^$CLASS$" noborder 1 lock -q
    hyprctl dispatch togglespecialworkspace term
    exit 0
fi

hyprctl dispatch togglespecialworkspace term
