# baxter_docker

Authors:  [Alejandro (Alex) Bordallo](https://github.com/GreatAlexander), [Emanuele De Peregin](https://github.com/Cryoscopic-E), [Heramb Modugula](https://github.com/heramb-modugula) (2025 - )

## Overview

This repo implements a docker container to work with the Baxter.

## Requirements

This repo does not require a ROS1 installation, everything is self-contained via Docker.

- Docker
- `vcs`: `pip install vcstool2` (alternatively, in Linux `sudo apt install vcstool`)
- VSCode/Codium

## Setup

1. Clone this repository

```bash
cd $HOME
mkdir workspaces
cd workspaces
git clone git@github.com/assistive-autonomy/baxter_docker
```
2. Import the package dependencies using `vcs`. Please note that the packages will live in the host system.

```bash
cd baxter_docker/src/
vcs import < sources.repos --recursive
```

3. Add Blurr IP and associated .local to host machine in /etc/hosts

4. Modify the static IP in blurr.env to match your local IP config

## Running the ESF demos

We have a nice TMux interface that loads multiple terminals, runs the initial setup scripts and preloads the exact commands to run.
```bash
cd ~/workspaces/baxter_docker
./baxter_session.sh
```

Remember to stop the container when you are done and reset xhost permissions (this will be fixed in the future to run on tmux exit)
```bash
docker compose -f ./docker/docker-compose-gui.yaml --env-file ./docker/blurr.env down
xhost -local:docker
```
