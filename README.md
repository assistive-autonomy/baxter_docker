# baxter_docker

Authors:  [Alejandro (Alex) Bordallo](https://github.com/GreatAlexander), [Emanuelle De Peregin](https://github.com/Cryoscopic-E), [Heramb Modugula](https://github.com/heramb-modugula) (2025 - )

## Overview

This package implements a devcontainer to work with the Baxter.


## Requirements

This package does not require a ROS1 installation, everything is self-contained via Docker.

- VSCode
- `vcs`: `pip install vcstool2` (alternatively, in Linux `sudo apt install vcstool`)
- Docker

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
vcs import < .repos --recursive
```

3. Open the folder with VSCode

4. Build the container directly using the Docker integration. For that, open the Command Palette (Ctlr+Shift+P on Linux,  ⌘ + P on Mac) and write "**_> Dev Containers: Rebuild and Open on Container_**". This will build the image and create a new container. VSCode will then refresh and _will reopen within the container_.


5. The new VSCode session will now _live_ in the container and any terminal you open will access the directories inside. The repositories will be automatically mounted in the container and should be available in `/opt/ros_ws/src`.


6. Build the ROS2 environment normally from any VSCode terminal:

```bash
cd /opt/ros_ws
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF --parallel-workers 2 --packages-up-to cooked_runtime
```

7. Source the workspace:

```bash
source install/setup.bash
```

### Launch Gazebo example

This example uses [**procman_ros**](https://www.github.com/assistive-autonomy/procman_ros) to manage the processes. It enables a simple way to keep all the commands we are interested in and also implement some basic scripts to launch distributed processes.

1. Start **procman** by running:

```bash
ros2 run procman_ros sheriff -l src/cooked_runtime/config/procman/cooked.pmd 
```

2. On the top menu, go to _Scripts -> drawing_demo_. This will open Gazebo, RVIz and will initialise the CRISP controllers.



### Closing devcontainer

To return to the normal VSCode window in the host system, we can again open the Command Palette and write "**_> Dev Containers: Reopen folder locally_**".

## Acknowledgments

- The Docker setup is based on the templates made by Tobit Flatscher in [docker-for-robotics](https://github.com/2b-t/docker-for-robotics)
- The instructions to set up the Franka codebase are from [franka_ros2](https://github.com/frankarobotics/franka_ros2/blob/humble/franka_gazebo/README.md) Additional installation tricks are taken from [ipab-rad/panda_ws](https://github.com/ipab-rad/panda_ws)
