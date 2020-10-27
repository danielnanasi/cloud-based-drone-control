#!/bin/bash

if [ ! -z $1 ] && [ $1 == 'kill' ]; then
    docker rm -f $(docker ps -a -q -f name=drone)
    exit
fi

cd "$(dirname "$0")"
source config.sh
source docker-credentials.sh

service_dir=$(pwd)
cd ${service_dir}/..
work_dir=$(pwd)
cd $service_dir
drone_control_dir=${work_dir}/${drone_control_dir_name}

echo "DEPLOY DRONES"
MASTER_IP=$(multipass list | grep $master | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
ROSCORE_IP=$(multipass exec $master -- kubectl get pods -o wide | grep roscore | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

for i in $(seq 1 ${NUMBER_OF_DRONES}); do

    echo 
    echo "DRONE-"$i":"

    SIMULATION_PORT=$((i-1+SIMULATION_START_PORT))
    FCU_PORT=$FCU_START_PORT

    echo "docker run --name drone-$i -e MASTER_IP=${ROSCORE_IP} -e MAVLINK_PORT=11311 -p ${SIMULATION_PORT}:10000 -p -p 14540-14580:14540-14580/udp -d nanasidnl/drone_control:px4sim"
    docker run --name drone-$i -e MASTER_IP=${ROSCORE_IP} -e MAVLINK_PORT=11311 -p ${SIMULATION_PORT}:10000 -p 14540-14580:14540-14580/udp -d nanasidnl/drone_control:px4sim

    sleep 1
done

echo
echo "DRONES LIST: "
docker ps -a -f name=drone
