#!/bin/bash

# -------------------------------------
# KUBERNETES (K3S) DEPLOYER CONFIG
# -------------------------------------

deployer_sleep_time=30

# master name
master="master"

# slaves name must be separated by space
slaves="slave-1 slave-2"

vms=$master" "$slaves

# master vm config
master_cpus=2
master_mem="2048M"
master_disk="25G"

# slaves vm config
slaves_cpus=2
slaves_mem="2048M"
slaves_disk="25G"

# -------------------------------------
# DRONE HQ DEPLOYER ON K3S CONFIG
# -------------------------------------

drone_control_dir_name="drone-control-2"
