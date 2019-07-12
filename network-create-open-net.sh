#!/usr/bin/env bash

source lib/util/util.sh

export CONSORTIUM_CONFIG=InviteConsortiumPolicy
export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-open-net.yaml -f multihost.yaml"
export DOMAIN=${DOMAIN:-example.com}


./network-create-base.sh orderer $@
