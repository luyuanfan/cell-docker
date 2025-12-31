#!/bin/bash
session="cell"
cu="cu"
du1="du_1"
du2="du_2"

if tmux has-session -t $session &>/dev/null; then
    tmux attach -t $session
    exit 0
fi

cu_cid=$(docker ps -qf name=$cu)
du1_cid=$(docker ps -qf name=$du1)
du2_cid=$(docker ps -qf name=$du2)

tmux new-session -d -s $session
tmux rename-window -t 0 'cell'
tmux split-window -h 
tmux split-window -h
tmux select-layout even-horizontal

tmux send-keys -t $session:0.0 "docker attach $cu_cid" C-l C-m
tmux send-keys -t $session:0.1 "docker attach $du1_cid" C-l C-m
tmux send-keys -t $session:0.2 "docker attach $du2_cid" C-l C-m

tmux attach-session -t $session

echo "TMUX session ended"