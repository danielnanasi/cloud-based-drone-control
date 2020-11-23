from drone import Drone
from configobj import ConfigObj
import json
import subprocess

def getiWorkerNodes():
    nodes=[]
    nodesJson = json.loads('{}')
    multipass_list= subprocess.check_output(["multipass", "list", "--format", "json"]).decode('utf-8')
    nodesJson= json.loads(multipass_list)
    configParser = ConfigObj('../config/config')
    masterName = configParser.get('master')
    
    for node in nodesJson['list']:
        if masterName not in node['name']:
            nodes.append(node)
    return nodes

if __name__ == "__main__":

    d = Drone(1, "10.253.192.64")
    print(d.getBetterNode(getiWorkerNodes(), 3))
