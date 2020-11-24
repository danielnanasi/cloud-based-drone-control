from drone import Drone
from configobj import ConfigObj
import json
import subprocess
import logger

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
            (isBetter, betterIP) = drone.getBetterNode(self.getWorkerNodes(), n)
            if isBetter:
                betterOptions.append({drone.drone_id : betterIP})
        return betterOptions

    def setDronesToNode(self, droneNodeList):
        for droneNodePair in droneNodeList:
            for d in self.drones:
                if d.drone_id == droneNodePair:
                    d.setNode(droneNodePair(droneNodePair))
                    logger.info("Drone-"+d.drone_id+" was set to node: "+droneNodePair(droneNodePair))

