#!/bin/bash

cd "$(dirname "$0")"
source ../config/configUp.sh
source ../config/docker-credentials.sh

echo "LOGGING IN INTO DOCKER"
docker login

echo "aruco"
docker build ${drone_control_dir}/vke_aruco/. -t nanasidnl/drone_control:aruco
docker push nanasidnl/drone_control:aruco

echo "commander"
docker build ${drone_control_dir}/vke_commander/. -t nanasidnl/drone_control:commander
docker push nanasidnl/drone_control:commander

echo "roscore"
docker build ${drone_control_dir}/vke_roscore/. -t nanasidnl/drone_control:roscore
docker push nanasidnl/drone_control:roscore
docker image rm -f $(docker image ls -q)

echo "px4sim"
docker build ${drone_control_dir}/vke_px4sim/. -t nanasidnl/drone_control:px4sim
docker push nanasidnl/drone_control:px4sim
