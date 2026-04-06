#!/usr/bin/env bash


# Enable XHost Server permissions
xhost +local:docker

# Build and launch docker container
docker compose -f ./docker/docker-compose-gui.yaml --env-file ./docker/blurr.env build

docker compose -f ./docker/docker-compose-gui.yaml --env-file ./docker/blurr.env up -d

# Load tmux config for esf-demo
if [ -z "$1" ]; then

	set -euo pipefail

	SESSION_NAME="esf-baxter-demo"
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
	tmux split-window -v -t "${SESSION_NAME}:main.2"

	tmux send-keys -t "${SESSION_NAME}:main.0" "docker exec -it baxter_devel bash" C-m
	tmux send-keys -t "${SESSION_NAME}:main.0" "./scripts/blurr.sh" C-m
	tmux send-keys -t "${SESSION_NAME}:main.0" C-b
	tmux send-keys -t "${SESSION_NAME}:main.0" "roslaunch ros_myo myo_demo.launch"

	tmux send-keys -t "${SESSION_NAME}:main.1" "docker exec -it baxter_devel bash" C-m
	tmux send-keys -t "${SESSION_NAME}:main.1" "./scripts/blurr.sh" C-m
	tmux send-keys -t "${SESSION_NAME}:main.1" C-b
	tmux send-keys -t "${SESSION_NAME}:main.1" "rosrun baxter_myo start_baxter.py"


	tmux send-keys -t "${SESSION_NAME}:main.2" "docker exec -it baxter_devel bash" C-m
	tmux send-keys -t "${SESSION_NAME}:main.2" "./scripts/blurr.sh" C-m
	tmux send-keys -t "${SESSION_NAME}:main.2" C-b
	tmux send-keys -t "${SESSION_NAME}:main.2" "roslaunch baxter_tower baxter_tower.launch"


	tmux send-keys -t "${SESSION_NAME}:main.3" "docker exec -it baxter_devel bash" C-m
	tmux send-keys -t "${SESSION_NAME}:main.3" "./scripts/blurr.sh" C-m
	tmux send-keys -t "${SESSION_NAME}:main.3" C-b 
	tmux send-keys -t "${SESSION_NAME}:main.3" "roslaunch baxter_tower april_tags.launch"

	tmux select-pane -t "${SESSION_NAME}:main.0"

	if [[ -n "${TMUX:-}" ]]; then
		tmux switch-client -t "${SESSION_NAME}"
	else
		exec tmux attach-session -t "${SESSION_NAME}"
	fi

fi

# Remember to run this after closing

# xhost +local:docker

# docker compose -f ./docker/docker-compose-gui.yaml --env-file ./docker/blurr.env down  
