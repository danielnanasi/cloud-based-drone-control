#!/bin/bash

cd "$(dirname "$0")"
source ../config/configUp.sh

# FIRST INSTALL MULTIPASS 
# sudo apt-get update
# sudo apt-get upgrade -y
# sudo snap install multipass --classic --stable

echo
echo "DELETE VMS IF EXIST"
for vm in $vms; do
    if [ $(multipass list | grep $vm | wc -l) -gt 0 ]; then
        echo "deleting "$vm
        multipass delete $vm --purge
        sleep ${deployer_sleep_time}
    fi
done


echo
echo "CREATE KUBERNETES VMS"
multipass launch --name $master --cpus $master_cpus --mem $master_mem --disk $master_disk

for slave in $slaves; do
    multipass launch --name $slave --cpus $slaves_cpus --mem $slaves_mem --disk $slaves_disk
    sleep ${deployer_sleep_time}
done

echo
echo "VMS LIST"
multipass list

sleep ${deployer_sleep_time}

echo
echo "UPDATE VMS"
for vm in $vms; do
    multipass exec $vm -- sudo apt-get update
    multipass exec $vm -- sudo apt-get upgrade -y
    multipass exec $vm -- sudo apt-get install iperf3 -y
    multipass exec $vm -- iperf3 -s & 
done

echo
echo "INIT MASTER"
multipass exec $master -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -"

sleep $((3*deployer_sleep_time))

K3S_TOKEN=$(multipass exec $master sudo cat /var/lib/rancher/k3s/server/node-token)
MASTER_IP=$(multipass list | grep $master | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

echo 
echo "MASTER_IP: "$MASTER_IP
echo "K3S TOKEN: "$K3S_TOKEN

for slave in $slaves; do
    echo
    echo "JOIN WORKER "$slave
    multipass exec $slave -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_TOKEN=${K3S_TOKEN} K3S_URL=https://${MASTER_IP}:6443 sh -"
    sleep ${deployer_sleep_time}
done

echo
echo "SCRIPT IS DONE, HERE IS THE CLUSTER INFORMATION: "

echo
multipass list
echo
multipass exec $master kubectl get nodes

echo
echo "APPLY LOADBALANCER"
multipass exec $master -- sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/traefik.yaml

echo
echo "PODS"
multipass exec $master -- kubectl get pods --all-namespaces
