#!/bin/bash

if [ ! -z $1 ] && [ $1 == 'kill' ]; then
    docker rm -f $(docker ps -a -q -f name=drone)
    exit
fi

cd "$(dirname "$0")"
source ../config/configUp.sh
source ../config/docker-credentials.sh

echo "DEPLOY DRONES"

for i in $(seq 1 ${NUMBER_OF_DRONES}); do

    echo 
    echo "DRONE-"$i":"

    SIMULATION_PORT=$((i-1+SIMULATION_START_PORT))
    
    FCU_PORT=$FCU_START_PORT
    
    ROSCORE_IP=$(multipass exec $master -- kubectl get pods -o wide | grep roscore-$i | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
    
    MAVLINK_PORT=$((i-1+MAVLINK_START_PORT))

    echo "docker run --name drone-$i -e ROS_IP=${ROSCORE_IP} -e ROS_MASTER_URI=http://${ROSCORE_IP}:${MAVLINK_PORT} -p ${SIMULATION_PORT}:10000 -p 14540-14580:14540-14580/udp -d nanasidnl/drone_control:px4sim"
    docker run --name drone-$i -e ROS_IP=${ROSCORE_IP} -e ROS_MASTER_URI=http://${ROSCORE_IP}:${MAVLINK_PORT} -p ${SIMULATION_PORT}:10000 -d nanasidnl/drone_control:px4sim

    sleep 1
done

echo
echo "DRONES LIST: "
docker ps -a -f name=drone
