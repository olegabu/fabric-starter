#!/usr/bin/env bash

: ${DOCKER_COMPOSE_ARGS:= -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-open-net.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml }
export DOCKER_COMPOSE_ARGS

./node-create.sh $@
