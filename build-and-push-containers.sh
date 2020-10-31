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

echo "aruco"
docker build ${drone_control_dir}/vke_aruco/. -t nanasidnl/drone_control:aruco
docker push nanasidnl/drone_control:aruco

echo "commander"
docker build ${drone_control_dir}/vke_commander/. -t nanasidnl/drone_control:commander
docker push nanasidnl/drone_control:commander
docker image rm -f $(docker image ls -q)

echo "px4sim"
docker build ${drone_control_dir}/vke_px4sim/. -t nanasidnl/drone_control:px4sim
docker push nanasidnl/drone_control:px4sim
