Cloud based drone control
----
Dipterv 1 - 2020 tavasz
Nánási Dániel
-------
### [Docomentation (coming soon)](docs/thesis.pdf)

### [Meeting logs](meetlogs.txt)

## Task planning
### TODO next semester
### TODO this semester
- [ ] Read about 5G solutions  
### TODO asap
- [ ] Docker compose --> Kubernetes yaml  
### In progress
- [ ] Write introduction  
- [ ] Working docker compose for 1 drone  
### DONE
- [x] Init git  
- [x] Get image  

## First cluster idea
![Alt text](first.png?raw=true "Kubernetes drone controll cluster v0.1")
Queue options: kafka? rabbitMQ? activeMQ?

## Docker image
https://hub.docker.com/r/bmehsnlab/aruco_detect_image_v2

## Containers communication
![Alt text](dontainer_communication.PNG?raw=true "Containers communications")
source: Welcome to R&D Innovation Days Budapest (presentation)

### containers waits data on:
- video_stream_opencv: (mantisvideo.launch) "rtsp://192.168.42.1:554/live"
- aruco detect: localhost:11311
- control ?


## Useful materials I used for learning
- Docker Tutorial course: https://www.youtube.com/watch?v=fqMOX6JJhGo
- Docker Compose tutorial: https://www.youtube.com/watch?v=Qw9zlE3t8Ko
- Kubernetes course: https://www.youtube.com/watch?v=Mi3Lx7yk3Hg
- ROS in 5 munutes: https://www.youtube.com/watch?v=pCBwos89fI0
