import docker
import re

class Drone():
    def __init__(self, drone_id, node_ip):
        self.drone_id=drone_id
        self.node_ip=node_ip

        self.docker_client = docker.from_env()

        self.drone= self.docker_client.containers.get("drone-"+str(self.drone_id))

    def getConnectionDelay(self, node_ip, n=1):
        pingCommand="ping "+node_ip+" -c "+str(n)
        (exit_code,output)= self.drone.exec_run(pingCommand)
        outputStr = output.decode('utf-8')
        for line in outputStr.split('\n'):
            if 'min/avg/max/mdev' in line:
                avg=line.split('/')[5]
                return float(avg)
        else:
            return 1000

    def getActualDelay(self, n=1):
        return self.getConnectionDelay(self.node_ip, n)

    def getBetterNode(self, nodes, n=1, ratio=0.9):
        existsBetterNode=False
        betterNodeIP=""
        for node in nodes:
            if(self.getActualDelay(n) < ratio*self.getConnectionDelay(node['ipv4'][0], n)):
                existsBetterNode= True
                betterNodeIP= node['ipv4'][0]
        return (existsBetterNode, betterNodeIP)
