#!/bin/bash

if [[ -z $TMUX ]]; then
	echo Run in tmux
	exit
fi

tmux split-window -d -p 20
tmux split-window -d -p 30
tmux split-window -d -p 50
tmux select-pane -t 0
tmux split-window -h
tmux select-pane -t 0
tmux split-window -d

tmux send-keys -t 0 C-U 'echo tab1' C-L
tmux send-keys -t 1 C-U 'echo tab2' C-L
tmux send-keys -t 2 C-L C-U 'echo tab3'
tmux send-keys -t 3 C-L C-U 'echo tab4'
tmux send-keys -t 4 C-L C-U 'echo tab5'
tmux send-keys -t 5 C-L C-U 'echo tab6'
tmux select-pane -t 5

tmux new-window
tmux send-keys -t 0 C-U 'echo new window' C-L
tmux select-window -t 0
