#!/usr/bin/env bash

docker rm -f $(docker ps -aq)
docker volume prune -f
sudo rm -rf crypto-config/
docker rmi -f $(docker images -q -f "reference=dev-*")
#docker rmi -f $(docker images -q -f "reference=olegabu/fabric-starter-client")

