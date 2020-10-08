#!/bin/bash
sleeptime=15

master="master"
slaves="slave-1 slave-2"

vms=$master" "$slaves

cpus=2
mem="2048M"
disk="10G"

echo
echo "INSTALL MULTIPASS"
sudo apt-get update
sudo apt-get upgrade -y
sudo snap install multipass --classic --stable

sleep $sleeptime

echo
echo "DELETE VMS IF EXIST"
for vm in $vms; do
    multipass delete $vm --purge
done

sleep $((2*sleeptime))

echo
echo "CREATE KUBERNETES VMS"
for vm in $vms; do
    echo
    echo "CREATE VM "$vm
    multipass launch --name $vm --cpus $cpus --mem $mem --disk $disk
    sleep $sleeptime
done

echo
echo "CREATED VMS LIST"
multipass list

echo
echo "INIT MASTER"
multipass exec $master -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -"

K3S_TOKEN=$(multipass exec $master sudo cat /var/lib/rancher/k3s/server/node-token)
MASTER_IP=$(multipass list | grep $master | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

echo 
echo "MASTER_IP: "$MASTER_IP
echo "K3S TOKEN: "$K3S_TOKEN

for slave in $slaves; do
    sleep $sleeptime
    multipass exec $slave -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_TOKEN=${K3S_TOKEN} K3S_URL=https://${MASTER_IP}:6443 sh -"
done

multipass exec $master kubectl get nodes
echo
echo "SCRIPT IS DONE, HOPE YOU SEE THE NODES IN THE CLUSTER"
