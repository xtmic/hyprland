#!/bin/bash

DISK_PCT=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_AVAIL=$(df -h / | awk 'NR==2 {print $4}')

printf '{"text": "󰋊 %s%%", "tooltip": "󰋊  %s / %s (%s%%)", "class": "disk", "percentage": %s}\n' \
    "$DISK_PCT" "$DISK_USED" "$DISK_AVAIL" "$DISK_PCT" "$DISK_PCT"
