#!/bin/bash
cd "$(dirname "$0")"

service_dir=$(pwd)
source config.sh
cd ${tools_dir}/../..
work_dir=$(pwd)
cd $tools_dir
drone_control_dir=${work_dir}/${drone_control_dir_name}

echo
echo "INSTALL DOCKER"

multipass exec ${master} -- sudo apt-get update
sleep 3
multipass exec ${master} -- sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
sleep 3
multipass exec ${master} -- curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sleep 3
multipass exec ${master} -- sudo apt-key fingerprint 0EBFCD88
sleep 3
multipass exec ${master} -- sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sleep 3
multipass exec ${master} -- sudo apt-get update
sleep 3
multipass exec ${master} -- sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sleep 10

echo
echo "INSTALL DOCKER COMPOSE"
multipass exec ${master} -- sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
sleep 3
multipass exec ${master} -- sudo chmod +x /usr/local/bin/docker-compose
sleep 3
multipass exec ${master} -- sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sleep 3
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
