#!/usr/bin/env bash


set -euo pipefail

SESSION_NAME="baxter-demo"
WORK_DIR="."

if ! command -v tmux >/dev/null 2>&1; then
	echo "Error: tmux is not installed or not in PATH." >&2
	exit 1
fi

if tmux has-session -t "${SESSION_NAME}" 2>/dev/null; then
	echo "Session '${SESSION_NAME}' already exists. Attaching..."
	exec tmux attach-session -t "${SESSION_NAME}"
fi

tmux new-session -d -s "${SESSION_NAME}" -c "${WORK_DIR}" -n main

tmux split-window -h -t "${SESSION_NAME}:main"
tmux split-window -v -t "${SESSION_NAME}:main.0"
tmux split-window -v -t "${SESSION_NAME}:main.1"

tmux send-keys -t "${SESSION_NAME}:main.0" "docker exec -it baxter_devel bash" C-m
tmux send-keys -t "${SESSION_NAME}:main.0" "./scripts/blurr.sh" C-m
tmux send-keys -t "${SESSION_NAME}:main.0" C-b

tmux send-keys -t "${SESSION_NAME}:main.1" "docker exec -it baxter_devel bash" C-m
tmux send-keys -t "${SESSION_NAME}:main.1" "./scripts/blurr.sh" C-m
tmux send-keys -t "${SESSION_NAME}:main.1" C-b
tmux send-keys -t "${SESSION_NAME}:main.1" "roslaunch ros_myo myo_demo.launch"


# tmux send-keys -t "${SESSION_NAME}:main.2" "docker exec -it baxter_devel bash" C-m
# tmux send-keys -t "${SESSION_NAME}:main.2" C-l 
# tmux send-keys -t "${SESSION_NAME}:main.2" "./scripts/blurr.sh && rosrun baxter_myo start_baxter"


# tmux send-keys -t "${SESSION_NAME}:main.3" "docker exec -it baxter_devel bash" C-m
# tmux send-keys -t "${SESSION_NAME}:main.3" C-l 
# tmux send-keys -t "${SESSION_NAME}:main.3" "./scripts/blurr.sh"

tmux select-pane -t "${SESSION_NAME}:main.0"

if [[ -n "${TMUX:-}" ]]; then
	tmux switch-client -t "${SESSION_NAME}"
else
	exec tmux attach-session -t "${SESSION_NAME}"
fi

