#!/bin/bash
layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -1)

case "$layout" in
    *English*) short="US" ;;
    *Russian*) short="RU" ;;
    *) short=$(echo "$layout" | sed -n 's/.*(\(.*\))/\1/p; s/^\(..\).*/\1/p') ;;
esac

echo "{\"text\": \"$short\", \"tooltip\": \"$layout\"}"
