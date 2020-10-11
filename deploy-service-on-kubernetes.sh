#!/bin/bash

cd "$(dirname "$0")"
source config.sh

service_dir=$(pwd)
cd ${service_dir}/..
work_dir=$(pwd)
cd $service_dir
drone_control_dir=${work_dir}/${drone_control_dir_name}

echo "OPERATIONS ON KUBERNETES MASTER: "
echo "MOUNT WORKING DIRECTORY"
multipass mount ${work_dir} ${master}

echo
echo "INSTALL DOCKER"
multipass exec ${master} -- sudo apt-get update
multipass exec ${master} -- sudo apt install apt-transport-https ca-certificates curl software-properties-common
multipass exec ${master} -- curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
multipass exec ${master} -- sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
multipass exec ${master} -- sudo apt update
multipass exec ${master} -- apt-cache policy docker-ce
multipass exec ${master} -- sudo apt install docker-ce
multipass exec ${master} -- sudo systemctl status docker

echo
echo "INSTALL DOCKER COMPOSE"
multipass exec ${master} -- sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
multipass exec ${master} -- sudo chmod +x /usr/local/bin/docker-compose
multipass exec ${master} -- sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
multipass exec ${master} -- docker-compose --version

echo
echo "BUILD CONTAINERS"
multipass exec ${master} -- sudo docker build ${drone_control_dir}/vke_roscore/. -t localhost:5000/roscore
multipass exec ${master} -- sudo docker build ${drone_control_dir}/vke_commander/. -t localhost:5000/commander
multipass exec ${master} -- sudo docker build ${drone_control_dir}/vke_px4sim/. -t localhost:5000/px4sim
multipass exec ${master} -- sudo docker build ${drone_control_dir}/vke_aruco/. -t localhost:5000/aruco

echo
echo "DOCKER IMAGE LIST"
multipass exec ${master} sudo docker image ls

echo
echo "DEPLOY LOCAL CONTAINER REGISTRY"
multipass exec ${master} -- sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2

sleep $deployer_sleep_time

echo
echo "PUSH CONTAINERS INTO THE LOCAL REGISTRY"
multipass exec ${master} -- sudo docker push localhost:5000/roscore
multipass exec ${master} -- sudo docker push localhost:5000/commander
multipass exec ${master} -- sudo docker push localhost:5000/px4sim
multipass exec ${master} -- sudo docker push localhost:5000/aruco

echo
echo "DEPLOY CONTAINERS AS A KUBERNETES SERVICE"
multipass exec ${master} -- sudo kubectl apply -f ${service_dir}/kube-drone-hq.yml

echo
echo "PODS LIST: "
multipass exec ${master} -- kubectl get pods --all-namespaces
