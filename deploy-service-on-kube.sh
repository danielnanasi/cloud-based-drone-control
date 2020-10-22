#!/bin/bash

if [ ! -z $1 ] && [ $1 == 'kill' ]; then
    multipass exec ${master} -- kubectl delete svc --all
    multipass exec ${master} -- kubectl delete deployment --all
fi

cd "$(dirname "$0")"
source config.sh
source docker-credentials.sh

service_dir=$(pwd)
cd ${service_dir}/..
work_dir=$(pwd)
cd $service_dir
drone_control_dir=${work_dir}/${drone_control_dir_name}

echo "OPERATIONS ON KUBERNETES MASTER: "
echo "MOUNT WORKING DIRECTORY"
multipass mount ${work_dir} ${master}

echo
echo "CREATE DOCKER REGISTRY SECRET FOR KUBERNETES"
multipass exec ${master} -- kubectl create secret docker-registry regcred --docker-server=${docker_server} --docker-username=${docker_username} --docker-password=${docker_password} --docker-email=${docker_email}

echo
echo "DEPLOY SERVICES ON KUBERNETES"
MASTER_IP=$(multipass list | grep $master | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
for i in $(seq 1 ${NUMBER_OF_DRONES}); do

    echo 
    echo "DRONE-"$i
    echo "-------------------------------------------------"

    DASHBOARD_PORT=$((i-1+DASHBOARD_START_PORT))
    MAVLINK_PORT=$((i-1+MAVLINK_START_PORT))
    FCU_PORT=$((i-1+FCU_START_PORT))

    multipass exec ${master} -- env MASTER_IP=${MASTER_IP} | tail -n 1
    multipass exec ${master} -- env DRONE_IP=${DRONE_IP} | tail -n 1
    multipass exec ${master} -- env DRONE_IDENTIFIER=${i} | tail -n 1
    multipass exec ${master} -- env DASHBOARD_PORT=${DASHBOARD_PORT} | tail -n 1
    multipass exec ${master} -- env MAVLINK_PORT=${MAVLINK_PORT} | tail -n 1
    multipass exec ${master} -- env FCU_PORT=${FCU_PORT} | tail -n 1

    multipass exec ${master} -- sudo kubectl apply -f ${service_dir}/kube-drone-hq.yml


    sleep 10
done

echo
echo "PODS LIST: "
multipass exec ${master} -- kubectl get pods -o wide
