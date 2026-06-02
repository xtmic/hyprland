#!/bin/bash

SESSION="bottomterm"

cleanup() {
    tmux kill-session -t "$SESSION" 2>/dev/null
}
trap cleanup EXIT

tmux new-session -d -s "$SESSION"

tmux set-option -t "$SESSION" status off
tmux set-option -t "$SESSION" mouse on
tmux set-window-option -t "$SESSION" pane-border-status top
tmux set-window-option -t "$SESSION" pane-border-format ' #[bold]#{pane_index} #{pane_title} '
tmux bind -n C-x kill-session

tmux split-window -h -t "$SESSION":1
tmux split-window -v -t "$SESSION":1.2

tmux select-pane -t "$SESSION":1.1 -T "Cava"
tmux select-pane -t "$SESSION":1.2 -T "Cmatrix"
tmux select-pane -t "$SESSION":1.3 -T "Peaclock"

tmux send-keys -t "$SESSION":1.1 'while true; do cava; done' Enter
sleep 0.3
tmux send-keys -t "$SESSION":1.2 'while true; do cmatrix -C blue -u 2; done' Enter
tmux send-keys -t "$SESSION":1.3 'while true; do peaclock; done' Enter

tmux attach -t "$SESSION"