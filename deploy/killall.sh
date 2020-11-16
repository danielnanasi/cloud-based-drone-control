#!/bin/bash

cd "$(dirname "$0")"
source ../../config.sh

for i in $(seq 1 $NUMBER_OF_DRONES); do
    multipass exec ${master} -- sudo kubectl delete -f ${service_dir}/kube-roscore-$i.yml
    rm kube-roscore-$i.yml
    multipass exec $master -- kubectl delete -f ${service_dir}/kube-drone-hq-$i.yml
    rm kube-drone-hq-$i.yml
done

docker rm -f $(docker ps -a -q -f name=drone)

exit
