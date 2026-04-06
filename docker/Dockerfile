ARG ROS_WS="/opt/ros_ws"

FROM osrf/ros:indigo-desktop-full AS base

# Setup ROS workspace folder
ARG ROS_WS
ENV ROS_WS=$ROS_WS

# Install basic dev tools (And clean apt cache afterwards)
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get -y --quiet --no-install-recommends install \
        wget \
        avahi-daemon \
        curl \
        g++ \
        libnss-mdns \
        ros-indigo-apriltags-ros \
        ros-indigo-baxter-sdk \
        clang-3.6 \
        python-pip \
        python-vcstool \
        nano \
        inetutils-ping \
        bash-completion \
        openssh-client \
    && rm -rf /var/lib/apt/lists/*

COPY ./deps $ROS_WS/deps

RUN pip install $ROS_WS/deps/enum34-1.1.10-py2-none-any.whl \
    && pip install $ROS_WS/deps/pyserial-3.5-py2.py3-none-any.whl

# Setup ROS workspace folder
WORKDIR $ROS_WS

# Enable ROS log colorised output
ENV RCUTILS_COLORIZED_OUTPUT=1

COPY ./scripts $ROS_WS/scripts
COPY ./config $ROS_WS/config

# Soft link to custom baxter .rviz config in scripts dir
RUN mkdir -p /root/.rviz
RUN ln -s $ROS_WS/config/rviz/baxter_tower.rviz /root/.rviz/default.rviz

# ---------------------------------------------------------------

FROM base AS prebuilt

ARG ROS_WS
ENV ROS_WS=$ROS_WS
WORKDIR $ROS_WS

COPY ./src/sources.repos $ROS_WS/src/sources.repos

RUN mkdir -p -m 0700 /root/.ssh \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN --mount=type=ssh \
    cd src \
    && vcs import < sources.repos --recursive

RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
    && catkin_make --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && catkin_make install

# ----------------------------------------------------------------

FROM prebuilt AS dev

ARG ROS_WS
ENV ROS_WS=$ROS_WS
WORKDIR $ROS_WS

# Add sourcing local workspace command to bashrc for
#    convenience when running interactively
RUN echo "source /opt/ros/indigo/setup.bash" >> /etc/bash.bashrc 
RUN echo "source /opt/ros_ws/install/setup.bash" >> /etc/bash.bashrc 

# Enter bash for development
ENTRYPOINT [ "/opt/ros_ws/scripts/blurr.sh" ]