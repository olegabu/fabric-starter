#!/usr/bin/env bash

docker rm -f $(docker ps -aq)
docker volume prune -f

sudo rm -rf crypto-config/

./generate-orderer.sh

echo "docker-compose -f docker-compose/docker-compose-orderer.yaml up"
docker-compose -f docker-compose/docker-compose-orderer.yaml up

