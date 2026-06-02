#!/bin/bash

THRONE_CLASS="Throne"

get_throne_addr() {
    hyprctl clients -j | jq -r ".[] | select(.class == \"$THRONE_CLASS\" and .mapped == true) | .address" | head -1
}

get_throne_hidden_addr() {
    hyprctl clients -j | jq -r ".[] | select(.class == \"$THRONE_CLASS\" and .workspace.name == \"special:throne\") | .address" | head -1
}

is_throne_focused() {
    local focused=$(hyprctl activewindow -j | jq -r '.class')
    [[ "$focused" == "$THRONE_CLASS" ]]
}

is_throne_hidden() {
    local addr=$(get_throne_hidden_addr)
    [[ -n "$addr" ]]
}

throne_has_window() {
    local addr=$(get_throne_addr)
    [[ -n "$addr" ]]
}

hide_throne() {
    local addr=$(hyprctl activewindow -j | jq -r '.address')
    if [[ -n "$addr" ]]; then
        hyprctl dispatch movetoworkspace "special:throne,address:$addr"
    fi
    pkill -RTMIN+8 waybar
}

show_throne() {
    local addr=$(get_throne_hidden_addr)
    if [[ -n "$addr" ]]; then
        hyprctl dispatch movetoworkspace "+0,address:$addr"
        sleep 0.15
        hyprctl dispatch focuswindow "class:^($THRONE_CLASS)$"
    fi
    pkill -RTMIN+8 waybar
}

launch_throne() {
    /usr/bin/throne &
    sleep 0.5
    hyprctl dispatch focuswindow "class:^($THRONE_CLASS)$"
}

case "${1:-}" in
    hide)
        if is_throne_focused; then
            hide_throne
        fi
        ;;
    show)
        if is_throne_hidden; then
            show_throne
        elif ! throne_has_window; then
            launch_throne
        else
            hyprctl dispatch focuswindow "class:^($THRONE_CLASS)$"
        fi
        ;;
    toggle)
        if is_throne_hidden; then
            show_throne
        elif is_throne_focused; then
            hide_throne
        elif throne_has_window; then
            hyprctl dispatch focuswindow "class:^($THRONE_CLASS)$"
        else
            launch_throne
        fi
        ;;
    status)
        if is_throne_hidden; then
            echo '{"text": "󰖩", "class": "hidden", "tooltip": "Throne (клик — открыть)"}'
        else
            echo '{"text": "", "class": ""}'
        fi
        ;;
    *)
        if is_throne_hidden; then
            echo '{"text": "󰖩", "class": "hidden", "tooltip": "Throne (клик — открыть)"}'
        else
            echo '{"text": "", "class": ""}'
        fi
        ;;
esac
