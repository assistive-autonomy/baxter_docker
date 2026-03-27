FROM osrf/ros:indigo-desktop-full AS base

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
        clang-3.6 \
        python-pip \
        # Command-line editor
        nano \
        # Ping network tools
        inetutils-ping \
        # Bash auto-completion for convenience
        bash-completion \
    && rm -rf /var/lib/apt/lists/*

COPY ./deps /opt/ros_ws/deps

RUN pip install /opt/ros_ws/deps/enum34-1.1.10-py2-none-any.whl \
    && pip install /opt/ros_ws/deps/pyserial-3.5-py2.py3-none-any.whl

# Setup ROS workspace folder
ENV ROS_WS=/opt/ros_ws
WORKDIR $ROS_WS

# Enable ROS log colorised output
ENV RCUTILS_COLORIZED_OUTPUT=1

COPY ./entrypoint.sh /

# Source ROS setup for dependencies and build our code
WORKDIR $ROS_WS
# RUN . /opt/ros/"$ROS_DISTRO"/setup.sh \
#     && catkin_make --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

COPY ./scripts $ROS_WS/scripts

# Soft link to custom baxter .rviz config in scripts dir
RUN mkdir -p /root/.rviz
RUN ln -s /opt/ros_ws/scripts/baxter_tower.rviz /root/.rviz/default.rviz

# RUN ./scripts/install-baxter-sdk.sh

# -----------------------------------------------------------------------

FROM base AS prebuilt

# Copy nebula artifacts/binaries from base to avoid re-compiling them
# RUN mkdir -p "$ROS_WS"/install
# COPY --from=base $ROS_WS/install "$ROS_WS"/install
# RUN mkdir -p "$ROS_WS"/build
# COPY --from=base "$ROS_WS"/build "$ROS_WS"/build

# Import all src folders
COPY ./src "$ROS_WS"/src

# Source ROS setup for dependencies and build our code
RUN . /opt/ros/"$ROS_DISTRO"/setup.sh \
    && catkin_make --cmake-args -DCMAKE_BUILD_TYPE=Release \
    && catkin_make install

# -----------------------------------------------------------------------

FROM prebuilt AS dev

ENV QT_X11_NO_MITSHM=1

# Copy prebuild nebula ros driver from base
# RUN mkdir -p "$ROS_WS"/install
# COPY --from=base "$ROS_WS"/install "$ROS_WS"/install
# RUN mkdir -p "$ROS_WS"/build
# COPY --from=base "$ROS_WS"/build "$ROS_WS"/build
# RUN mkdir -p "$ROS_WS"/log
# COPY --from=base "$ROS_WS"/log "$ROS_WS"/log

# Install basic dev tools (And clean apt cache afterwards)
# RUN apt-get update \
#     && DEBIAN_FRONTEND=noninteractive \
#         apt-get -y --quiet --no-install-recommends install \
#         # Command-line editor
#         nano \
#         # Ping network tools
#         inetutils-ping \
#         # Bash auto-completion for convenience
#         bash-completion \
#     && rm -rf /var/lib/apt/lists/*

# Add sourcing local workspace command to bashrc for
#    convenience when running interactively
RUN echo "source /opt/ros_ws/devel/setup.bash" >> /etc/bash.bashrc

# Source Baxter (BLURR) configuration
# RUN /opt/ros_ws/scripts/blurr.sh

# Enter bash for development
# ENTRYPOINT [ "/entrypoint.sh" ]
ENTRYPOINT [ "/opt/ros_ws/scripts/blurr.sh" ]

# -----------------------------------------------------------------------

FROM base AS runtime

# Copy artifacts/binaries from prebuilt
COPY --from=prebuilt "$ROS_WS"/src "$ROS_WS"/src
COPY --from=prebuilt "$ROS_WS"/install "$ROS_WS"/install
COPY --from=prebuilt "$ROS_WS"/build "$ROS_WS"/build

# Add command to docker entrypoint to source newly compiled
#   code when running docker container
RUN sed --in-place --expression \
        "\$isource \"$ROS_WS/install/setup.bash\" " \
        /ros_entrypoint.sh

# launch ros package
CMD ["ros", "launch", "baxter_docker_launch", "baxter.launch"]