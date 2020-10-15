#!/bin/bash

cd "$(dirname "$0")"
source config.sh
source docker-credentials.sh

service_dir=$(pwd)
cd ${service_dir}/..
work_dir=$(pwd)
cd $service_dir
drone_control_dir=${work_dir}/${drone_control_dir_name}


echo "LOGGING IN INTO DOCKER"
docker login

echo
echo "BUILD CONTAINERS"
docker build ${drone_control_dir}/vke_roscore/. -t nanasidnl/drone_control:roscore
docker build ${drone_control_dir}/vke_aruco/. -t nanasidnl/drone_control:aruco
docker build ${drone_control_dir}/vke_commander/. -t nanasidnl/drone_control:commander
docker build ${drone_control_dir}/vke_px4sim/. -t nanasidnl/drone_control:px4sim

echo
echo "PUSH CONTAINERS"
docker push nanasidnl/drone_control:roscore
docker push nanasidnl/drone_control:aruco
docker push nanasidnl/drone_control:commander
docker push nanasidnl/drone_control:px4sim
