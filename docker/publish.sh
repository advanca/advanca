#!/bin/bash
#
# This script is used by Advanca authors to publish images to docker hub repository https://hub.docker.com/u/advanca
#
# Instructions:
#
# 1. Make sure the following images are built
#    - advanca-node:latest
#    - advanca-worker:latest
#    - advanca-client:latest
#
# 2. Modify the version tags variables in this script
# 3. Make sure you have the write access to docker hub and execute the script

# NOTE: remember to modify the version tags before publishing
node_version=0.1.0
worker_version=0.2.0
client_version=0.2.0

docker tag advanca-node:latest advanca/advanca-node:latest
docker push advanca/advanca-node:latest

docker tag advanca-node:latest advanca/advanca-node:${node_version}
docker push advanca/advanca-node:${node_version}

docker tag advanca-worker:latest advanca/advanca-worker:latest
docker push advanca/advanca-worker:latest

docker tag advanca-worker:latest advanca/advanca-worker:${worker_version}
docker push advanca/advanca-worker:${worker_version}

docker tag advanca-client:latest advanca/advanca-client:latest
docker push advanca/advanca-client:latest

docker tag advanca-client:latest advanca/advanca-client:${client_version}
docker push advanca/advanca-client:${client_version}