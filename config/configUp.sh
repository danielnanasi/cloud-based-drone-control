#!/bin/bash

cd ../config
config_dir=$(pwd)
source config

cd $config_dir"/../kubernetes"
service_dir=$(pwd)

cd ${config_dir}"/../.."
work_dir=$(pwd)

cd $service_dir
drone_control_dir=${work_dir}"/drone-control-2"

