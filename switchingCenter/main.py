from drone import Drone
from switch import SwitchingCenter
from time import sleep
import logging
import sys

if __name__ == "__main__":
    logging.basicConfig(filename='switchCenter.log', level=logging.INFO, format='%(asctime)s %(levelname)-8s %(message)s')

    sw = SwitchingCenter()
    logging.info('Switching center program started!')
    while(1):
        betterOptions = sw.searchAllDroneBetterOption(n=10)
        sw.setDronesToNode(betterOptions)

        sleep(10)

