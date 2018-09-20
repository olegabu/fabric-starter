#!/usr/bin/env bash

./generate-orderer.sh

echo "docker-compose -f docker-compose/docker-compose-orderer.yaml up"
docker-compose -f docker-compose/docker-compose-orderer.yaml up

