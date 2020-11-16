#!/bin/bash

cd "$(dirname "$0")"
source ../config/configUp.sh
source ../config/docker-credentials.sh

if [ ! -z $1 ] && [ $1 == 'kill' ]; then
    for i in $(seq 1 $NUMBER_OF_DRONES); do
        multipass exec $master -- kubectl delete -f ${service_dir}/kube-drone-hq-$i.yml
        rm kube-drone-hq-$i.yml
    done
    exit
fi

echo "OPERATIONS ON KUBERNETES MASTER: "
echo "MOUNT WORKING DIRECTORY"
multipass mount ${work_dir} ${master}

echo
echo "CREATE DOCKER REGISTRY SECRET FOR KUBERNETES"
multipass exec ${master} -- kubectl create secret docker-registry regcred --docker-server=${docker_server} --docker-username=${docker_username} --docker-password=${docker_password} --docker-email=${docker_email}

MASTER_IP=$(multipass list | grep $master | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
ROSCORE_IP=$(multipass list | grep $ROSCORE_NODE | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

echo
echo "DEPLOY DRONE-HQS ON KUBERNETES"
for i in $(seq 1 ${NUMBER_OF_DRONES}); do

    echo 
    echo "DRONE-"$i
    echo "-------------------------------------------------"

    DASHBOARD_PORT=$((i-1+DASHBOARD_START_PORT))
    FCU_PORT=$((i-1+FCU_START_PORT))
    COMMANDER_NODE_PORT=$((i-1+COMMANDER_START_NODE_PORT))
    MAVLINK_PORT=$((i-1+MAVLINK_START_PORT))

    DRONE_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -q -f name=drone-$i))
    cp kube-drone-hq.yml kube-drone-hq-$i.yml

    sed -i 's/$(MASTER_IP)/'${MASTER_IP}'/g' kube-drone-hq-$i.yml
    sed -i 's/$(DRONE_IP)/'${DRONE_IP}'/g' kube-drone-hq-$i.yml
    sed -i 's/$(DRONE_IDENTIFIER)/'${i}'/g' kube-drone-hq-$i.yml
    sed -i 's/$(SIMULATION_START_PORT)/'${SIMULATION_START_PORT}'/g' kube-drone-hq-$i.yml
    sed -i 's/$(ROSCORE_IP)/'${ROSCORE_IP}'/g' kube-drone-hq-$i.yml
    sed -i 's/$(MAVLINK_PORT)/'${MAVLINK_PORT}'/g' kube-drone-hq-$i.yml
    sed -i 's/$(FCU_PORT)/'${FCU_PORT}'/g' kube-drone-hq-$i.yml
    sed -i 's/$(COMMANDER_PORT)/'${COMMANDER_PORT}'/g' kube-drone-hq-$i.yml
    sed -i 's/$(COMMANDER_NODE_PORT)/'${COMMANDER_NODE_PORT}'/g' kube-drone-hq-$i.yml

    multipass exec ${master} -- sudo kubectl apply -f ${service_dir}/kube-drone-hq-$i.yml

    sleep 1
done

echo
echo "PODS LIST: "
multipass exec ${master} -- kubectl get pods

echo
echo "SERVICES LIST: "
multipass exec ${master} -- kubectl get svc
