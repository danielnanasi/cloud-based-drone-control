Cloud based drone control
----
Diplomaterv 2020
Nánási Dániel
-------
### [Dipterv doksi](docs/thesis.pdf)

## Containers communication
![Alt text](dontainer_communication.PNG?raw=true "Containers communications")
source: Welcome to R&D Innovation Days Budapest (presentation)

## Requiments
First install Multipass
```
sudo apt install multipass
```
The drone-control-2 must be in the same directory with this repo.

## Deploy K3S on Multipass VMs
After configure the vms in config.sh
```
vi config.sh
# ...
```
After run the script
```
bash deploy-kubernetes-on-ubuntu.sh
```

## Deploy drone control service on K3S cluster
Then deploy the drone control containers too 
```
deploy-service-on-kubernetes.sh
```

## Useful materials I used for learning
- Docker Tutorial course: https://www.youtube.com/watch?v=fqMOX6JJhGo
- Docker Compose tutorial: https://www.youtube.com/watch?v=Qw9zlE3t8Ko
- Kubernetes course: https://www.youtube.com/watch?v=Mi3Lx7yk3Hg
- ROS in 5 munutes: https://www.youtube.com/watch?v=pCBwos89fI0
- Mantis Q documentation: https://us.yuneec.com/files/downloads/mantis-q/Mantis%20Q_USER%20MANUAL_V1.0_20180921.pdf
