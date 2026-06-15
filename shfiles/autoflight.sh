#!/bin/bash

PROJECT_NAME="Explorer-lidar"
WS_PATH=~/$PROJECT_NAME  # 工作空间完整路径

echo "========== START SENSOR =========="

BASE_LOG_DIR=$WS_PATH/logs
TIME=$(date +%Y%m%d_%H%M%S)
LOG_DIR=$BASE_LOG_DIR/$TIME

mkdir -p $LOG_DIR
mkdir -p $WS_PATH/bags

echo "Logs will be saved to: $LOG_DIR"

# =========================
# SENSOR
# =========================
gnome-terminal -- bash -c "
source $WS_PATH/devel/setup.bash

{
sudo chmod 777 /dev/ttyACM0 & sleep 2;
roslaunch mavros px4.launch & sleep 3;
rosrun mavros mavcmd long 511 105 5000 0 0 0 0 0 & sleep 1;
rosrun mavros mavcmd long 511 31 5000 0 0 0 0 0 & sleep 1;
roslaunch livox_ros_driver2 msg_MID360.launch;
} 2>&1 | tee $LOG_DIR/sensor.log

exec bash
"

sleep 5

# =========================
# MAPPING
# =========================
echo "========== START MAPPING =========="

gnome-terminal -- bash -c "
source $WS_PATH/devel/setup.bash

roslaunch fast_lio mapping_mid360.launch rviz:=false \
2>&1 | tee $LOG_DIR/mapping.log

exec bash
"

sleep 5

# =========================
# PLANNER
# =========================
echo "========== START PLANNER =========="

gnome-terminal -- bash -c "
source $WS_PATH/devel/setup.bash

roslaunch exploration_manager run_in_exp.launch \
2>&1 | tee $LOG_DIR/path_planner.log

exec bash
"

sleep 3

# =========================
# PX4 CTRL（已加日志）
# =========================
echo "========== START PX4 CTRL =========="

gnome-terminal -- bash -c "
source $WS_PATH/devel/setup.bash

roslaunch px4ctrl run_ctrl.launch \
2>&1 | tee $LOG_DIR/px4ctrl.log

exec bash
"

# =========================
# ROSBAG RECORD
# =========================
echo "========== START ROSBAG RECORD =========="

gnome-terminal -- bash -c "
source $WS_PATH/devel/setup.bash;
rosbag record --tcpnodelay -O $WS_PATH/bags/bag_$TIME \
/path \
/Odom_high_freq \
/cloud_registered \
/position_cmd \
/planning/bspline \
/planning/position_cmd_vis \
/planning/travel_traj \
/sdf_map/occupancy_local \
/sdf_map/occupancy_local_inflate \
/planning_vis/frontier \
/planning_vis/viewpoints;

exec bash
"

echo "========== ALL MODULES STARTED =========="
echo "Logs saved in: $LOG_DIR"