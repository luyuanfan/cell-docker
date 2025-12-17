#!/bin/bash
session="cell"
cu="cu"
du1="du_1"
du2="du_2"
session_exists=$(tmux ls | grep $session)

cu_cid=$(docker ps -qf name=$cu)
du1_cid=$(docker ps -qf name=$du1)
du2_cid=$(docker ps -qf name=$du2)

tmux new-session -d -s $session
tmux rename-window -t 0 'cell'
tmux split-window -h 
tmux split-window -h
tmux select-layout even-horizontal

tmux send-keys -t $session:0.0 "echo 'ho <serving pci> <rnti> <target pci>'" C-m
tmux send-keys -t $session:0.0 "docker attach $cu_cid" C-m
tmux send-keys -t $session:0.1 "docker attach $du1_cid" C-m
tmux send-keys -t $session:0.2 "docker attach $du2_cid" C-m

tmux attach-session -t $session