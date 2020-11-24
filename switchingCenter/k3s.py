from configobj import ConfigObj
import subprocess
import kubernetes
import logger

class DroneHQmanager:
    def __init__(drone_id):
        self.config_parser = ConfigObj('../config/config')
        aToken= subprocess.check_output(["multipass", "exec", self.config_parser.get('master'), "--", "kubectl describe secret $SECRET_NAME | grep -E '^token' | cut -f2 -d':' | tr -d " ")"]).decode('utf-8')
        master_ip= subprocess.check_output(["multipass", "list", "|", "grep", self.config_parser.get('master'),'grep -oE \b([0-9]{1,3}\.){3}[0-9]{1,3}\b']).decode('utf-8')

        aConfiguration = kubernetes.client.Configuration()
        aConfiguration.verify_ssl = False
        aConfiguration.host = "https://"+master_ip+":443"

        aConfiguration.api_key = {"authorization": "Bearer " + aToken}

        aApiClient = kubernetes.client.ApiClient(aConfiguration)

        self.kApi = client.CoreV1Api(aApiClient)

        logger.info("Logged into the Kubernetes master:")
        logger.info("Master IP: "+ master_ip)
        logger.info("Master token: "+ k3s_token)
        logger.info("Pods: ")

        ret = self.kApi.list_pod_for_all_namespaces(watch=False)
        for i in ret.items:
            logger.info("%s\t%s\t%s" % (i.status.pod_ip, i.metadata.namespace, i.metadata.name))

