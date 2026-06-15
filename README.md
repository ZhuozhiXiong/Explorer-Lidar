# Explorer-lidar

Explorer-lidar is a ROS/catkin project for LiDAR-based active exploration with aerial robots. It integrates frontier-based exploration, local mapping, trajectory planning, obstacle avoidance, simulation sensing, and real-world flight modules for UAV experiments.

The project supports both simulation demos, such as bridge and tower exploration, and real-flight experiments with LiDAR, SLAM/LIO, MAVROS, PX4, and onboard planning.

## Demo

| Aerial Robot |
| --- |
| ![Aerial robot](images/aerial%20robot.jpg) |

| SLAM - Park | SLAM - Zhishanting |
| --- | --- |
| ![SLAM park demo](images/slam_park.gif) | ![SLAM zhishanting demo](images/slam_zhishanting.gif) |

| Obstacle Avoidance |
| --- |
| ![Obstacle avoidance](images/obstacle_avoidance.gif) |

| Active Exploration |
| --- |
| ![Exploration demo](images/explore.gif) |

## Features

- LiDAR-based active exploration in unknown environments
- Occupancy/ESDF map construction and local map update
- Frontier detection, viewpoint selection, and TSP-based visiting order optimization
- B-spline trajectory generation, optimization, and visualization
- SO3 quadrotor simulation, disturbance simulation, and RViz visualization
- Real-world interfaces for MID360/FAST-LIO, MAVROS, PX4 control, and rosbag recording

## Repository Structure

```text
.
├── images/                         # README images and GIF demos
├── shfiles/                        # Real-flight scripts for takeoff, landing, autonomous flight, and rosbag recording
└── src/
    ├── exploration/                # Exploration manager, active perception, and TSP utilities
    ├── fast_planner/               # Path search, trajectory optimization, and planning management
    ├── realflight_modules/         # PX4 control, VINS, Realsense, MID360 FAST-LIO
    ├── uav_simulator/              # Quadrotor, SO3 control, map, and sensor simulation
    └── utils/                      # Messages, RViz plugins, visualization, and common utilities
```

## Quick Start

This project has been tested on Ubuntu 20.04 with ROS Noetic

### 1. Install NLOPT

Install `nlopt v2.7.1`:

```bash
git clone -b v2.7.1 https://github.com/stevengj/nlopt.git
cd nlopt
mkdir build
cd build
cmake ..
make
sudo make install
```

### 2. Install Common ROS and System Dependencies

```bash
sudo apt update
sudo apt install -y \
  ros-noetic-desktop-full \
  ros-noetic-mavros ros-noetic-mavros-extras \
  ros-noetic-pcl-ros ros-noetic-cv-bridge ros-noetic-image-transport \
  ros-noetic-tf ros-noetic-rviz ros-noetic-nodelet \
  ros-noetic-ddynamic-reconfigure \
  libeigen3-dev libpcl-dev libopencv-dev libarmadillo-dev \
  liblapack-dev libsuitesparse-dev libcxsparse3.1.2 \
  libgflags-dev libgoogle-glog-dev libgtest-dev \
  libglew-dev libglfw3-dev
```

Install the MAVROS GeographicLib datasets:

```bash
cd /opt/ros/noetic/lib/mavros
sudo ./install_geographiclib_datasets.sh
```

### 3. Install Intel RealSense Driver

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || \
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE

sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u
sudo apt-get install -y librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg
```

Test the camera with:

```bash
realsense-viewer
```

Make sure the USB mode shown in the upper-left corner is `3.x`. If it shows `2.x`, check whether the USB cable or port only supports USB 2.0. USB 3.0 cables and ports are usually blue.

### 4. Install Ceres and glog

If you use the provided `3rd_party.zip`, extract it first.

Build and install `glog`:

```bash
cd glog
./autogen.sh
./configure
make
sudo make install
```

Build and install `ceres`:

```bash
cd ceres
mkdir build
cd build
cmake ..
sudo make -j4
sudo make install
```

### 5. Install Livox SDK2

```bash
git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd Livox-SDK2
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install
```

Installing Livox SDK2 system-wide is important so that CMake can find it.

### 6. Clone and Build Explorer-lidar

```bash
cd ${YOUR_WORKSPACE_PATH}/src
git clone <this-repository-url> Explorer-lidar
cd ..
catkin_make
source devel/setup.bash
```

If this repository is already your catkin workspace root, build it directly:

```bash
cd ~/Explorer-lidar
source /opt/ros/noetic/setup.bash
catkin_make
source devel/setup.bash
```

If your workspace path is not `~/Explorer-lidar`, replace the path with your actual location. The script `shfiles/autoflight.sh` uses `~/Explorer-lidar` as the default workspace path, so update `WS_PATH` in that script if needed.

## Run the Project

Before launching any demo, source the workspace:

```bash
cd ~/Explorer-lidar
source devel/setup.bash
```

### Real-World Experiment

```bash
roslaunch exploration_manager run_in_exp.launch
```

Launch file:

```text
src/exploration/exploration_manager/launch/run_in_exp.launch
```

Default subscribed topics:

- Odometry: `/Odom_high_freq`
- Registered world-frame point cloud: `/cloud_registered`

This launch file starts the exploration planner and trajectory server. It is intended for experiments where the external SLAM/LIO, point cloud, and flight-control links are already running.

### Bridge Simulation

```bash
roslaunch exploration_manager sim_bridge.launch
```

Launch file:

```text
src/exploration/exploration_manager/launch/sim_bridge.launch
```

This launch file starts RViz, the exploration algorithm, trajectory server, trajectory recorder, SO3 quadrotor simulator, disturbance simulator, map publisher, and LiDAR/depth sensing simulation. The default map is `bridge.pcd`.

### Tower Simulation

```bash
roslaunch exploration_manager sim_tower.launch
```

Launch file:

```text
src/exploration/exploration_manager/launch/sim_tower.launch
```

This launch file is similar to the bridge simulation and uses `tower.pcd` as the default map.

## Useful Parameters

The main launch files expose commonly used parameters:

- `map_size_x/y/z`: map size
- `init_x/y/z`: initial UAV position in simulation
- `box_min_x/y/z`, `box_max_x/y/z`: exploration boundary
- `max_vel`, `max_acc`: velocity and acceleration limits
- `resolution`: map resolution
- `odom_topic`, `cloud_topic`, `depth_topic`: state and sensor topics

More algorithm parameters can be found in:

```text
src/exploration/exploration_manager/launch/algorithm_exp.xml
src/exploration/exploration_manager/launch/algorithm_sim_bridge.xml
src/exploration/exploration_manager/launch/algorithm_sim_tower.xml
```

## Real-Flight Helper Scripts

The `shfiles/` directory provides helper scripts for real-world experiments:

```bash
bash shfiles/autoflight.sh   # Start sensors, mapping, planning, PX4 control, and rosbag recording
bash shfiles/takeoff.sh      # Send takeoff command
bash shfiles/land.sh         # Send landing command
bash shfiles/record.sh       # Record common exploration topics
```

Before running real-flight scripts, make sure the flight controller, RC transmitter, safety switch, emergency stop procedure, device permissions, and ROS topics are correctly configured.

## Visualization and Data Recording

- Simulation launch files start RViz automatically.
- Trajectory records are saved to `exploration_manager/data` by default.
- `autoflight.sh` saves logs to `logs/<time>/` and rosbag files to `bags/`.

## Notes for Uploading to GitHub

Avoid committing local build outputs, logs, and rosbag files:

```text
build/
devel/
logs/
bags/
*.bag
```

This repository contains several third-party and modified modules. Before a public release, please add the required license information and check the original license terms of each dependency.

## Acknowledgements

This project is mainly inspired by and references:

- [HKUST-Aerial-Robotics/FUEL](https://github.com/HKUST-Aerial-Robotics/FUEL)
- [Robotics-STAR-Lab/SOAR](https://github.com/Robotics-STAR-Lab/SOAR)

The real-world flight setup also refers to:

- [ZJU-FAST-Lab/Fast-Drone-250](https://github.com/ZJU-FAST-Lab/Fast-Drone-250)
- [NEU-REAL/REAL_DRONE_400](https://github.com/NEU-REAL/REAL_DRONE_400)

Some prerequisite installation steps are shared with or adapted from these projects. We sincerely thank the authors and contributors for their open-source work.
