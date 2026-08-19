# Explorer-Lidar
[![ROS Noetic](https://img.shields.io/badge/ROS-Noetic-blue)](http://wiki.ros.org/noetic)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04-orange)](https://releases.ubuntu.com/20.04/)
[![Language](https://img.shields.io/badge/Language-C++-blue)](https://isocpp.org/)

Explorer-Lidar is a ROS/catkin project for LiDAR-based autonomous exploration with aerial robots. It integrates Lidar-based SLAM, frontier-based exploration, local mapping, path planning, trajectory generation and controller for UAV experiments to explore unseen environments and obtain 3D point cloud of structures.

The project supports both simulation demos, such as bridge and tower exploration, and real-flight experiments with LiDAR, Fast-LIO, MAVROS, PX4, and onboard planning.

## Demo

| Aerial Robot |
| --- |
| <img src="images/aerial%20robot.jpg" alt="Aerial Robot" width="600">|

| SLAM - Park | SLAM - Zhishanting |
| --- | --- |
| ![SLAM park demo](images/slam_park.gif) | ![SLAM zhishanting demo](images/slam_zhishanting.gif) |

| Obstacle Avoidance |
| --- |
| ![Obstacle avoidance](images/obstacle_avoidance.gif) |

| Autonomous Exploration |
| --- |
| ![Exploration demo](images/explore.gif) |

| Autonomous Inspection |
| --- |
| ![Inspection demo](images/inspection.gif) |

## Features

- LiDAR-based autonomous exploration in unknown environments
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

This project has been tested on Ubuntu 20.04 with ROS Noetic. The installation can be referenced to [ZJU-FAST-Lab/Fast-Drone-250](https://github.com/ZJU-FAST-Lab/Fast-Drone-250) and [NEU-REAL/REAL_DRONE_400](https://github.com/NEU-REAL/REAL_DRONE_400) for detailed information.

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
  liblapack-dev libsuitesparse-dev libcxsparse3.0 \
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

If there is a problem in installing this driver, you can refer to [RealenseSDK-FIX](https://github.com/Hyper-jiawei/-Fastlab-Fast-drone-250-realenseSDK-FIX-).

### 4. Install Livox SDK2

```bash
git clone https://github.com/Livox-SDK/Livox-SDK2.git
cd Livox-SDK2
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install
```

### 5. Clone and Build Explorer-lidar

```bash
git clone https://github.com/ZhuozhiXiong/Explorer-Lidar.git
cd Explorer-Lidar
catkin_make
```

To simulate the depth camera, we use a simulator based on CUDA Toolkit. Please install it first following the [instruction of CUDA](https://developer.nvidia.com/zh-cn/cuda-toolkit). 

After successful installation, in the **local_sensing** package in **uav_simulator**, remember to change the 'arch' and 'code' flags in CMakelist.txt according to your graphics card devices.

If you cannot get access to CUDA, you can use the CPU version instead by revising **set(ENABLE_CUDA false)** in CMakelist.txt.

## Run the Project

Before launching any demo, source the workspace:

```bash
cd Explorer-Lidar
source devel/setup.bash
```

### Bridge Simulation

```bash
roslaunch exploration_manager sim_bridge.launch
```

Launch file:

```text
src/exploration/exploration_manager/launch/sim_bridge.launch
```

This launch file starts RViz, the exploration algorithm, trajectory server, trajectory recorder, SO3 quadrotor simulator, disturbance simulator, map publisher, and LiDAR/depth sensing simulation. The default map is `bridge.pcd`.

y default you can see an bridge environment. Trigger the quadrotor to start inspection by the ```2D Nav Goal``` tool in ```Rviz```. The FoV and trajectories of the quadrotor are displayed.

### Tower Simulation

```bash
roslaunch exploration_manager sim_tower.launch
```

Launch file:

```text
src/exploration/exploration_manager/launch/sim_tower.launch
```

This launch file is similar to the bridge simulation and uses `tower.pcd` as the default map.

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

This launch file starts the exploration planner and trajectory server. It is intended for experiments where the external SLAM/LIO, point cloud, and flight-control links are already running by using `sh shfiles/autoflight.sh` in another terminal.

## Real-Flight Helper Scripts

The `shfiles/` directory provides helper scripts for real-world experiments:

```bash
sh shfiles/autoflight.sh   # Start sensors, mapping, planning, PX4 control, and rosbag recording
sh shfiles/takeoff.sh      # Send takeoff command
sh shfiles/land.sh         # Send landing command
sh shfiles/record.sh       # Record common exploration topics
```

Before running real-flight scripts, make sure the flight controller, RC transmitter, safety switch, emergency stop procedure, device permissions, and ROS topics are correctly configured.

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

## Acknowledgements

This project is mainly inspired by and references:

- [HKUST-Aerial-Robotics/FUEL](https://github.com/HKUST-Aerial-Robotics/FUEL)
- [Robotics-STAR-Lab/SOAR](https://github.com/Robotics-STAR-Lab/SOAR)

The real-world flight setup also refers to:

- [ZJU-FAST-Lab/Fast-Drone-250](https://github.com/ZJU-FAST-Lab/Fast-Drone-250)
- [NEU-REAL/REAL_DRONE_400](https://github.com/NEU-REAL/REAL_DRONE_400)

Some prerequisite installation steps are shared with or adapted from these projects. We sincerely thank the authors and contributors for their open-source work.
