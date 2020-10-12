#!/bin/bash

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
echo "DEPLOY CONTAINERS AS A KUBERNETES SERVICE"
multipass exec ${master} -- sudo kubectl apply -f ${service_dir}/kube-drone-hq.yml

echo
echo "PODS LIST: "
sleep 30
multipass exec ${master} -- kubectl get pods --all-namespaces
