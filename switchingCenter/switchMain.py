from drone import Drone
from configobj import ConfigObj
import json
import subprocess

class SwitchingCenter():
    def __init__(self):
        self.config_parser = ConfigObj('../config/config')
        self.droneNum = int(self.config_parser.get('NUMBER_OF_DRONES'))
        self.drones = []
        for drone_id in range(1, self.droneNum):
            self.drones.append(Drone(drone_id, self.getWorkerNode('worker-1')['ipv4'][0]))

    def getWorkerNodes(self):
        nodes=[]
        nodesJson = json.loads('{}')
        multipass_list= subprocess.check_output(["multipass", "list", "--format", "json"]).decode('utf-8')
        nodesJson= json.loads(multipass_list)
        masterName = self.config_parser.get('master')
        
        for node in nodesJson['list']:
            if masterName not in node['name']:
                nodes.append(node)
        return nodes

    def getWorkerNode(self, name):
        workerNode = {}
        for node in self.getWorkerNodes():
            if(node['name'] == name):
                workerNode = node
        return workerNode

    def searchAllDroneBetterOption(self, n=1):
        betterOptions=[]
        for drone in self.drones:
            (isBetter, betterIP) = drone.getBetterNode(n)
            if isBetter:
                drone.setNode(betterIP)


if __name__ == "__main__":

    sw = SwitchingCenter()
    d = Drone(1, "10.253.192.64")
    print(d.getBetterNode(sw.getWorkerNodes(), 3))
