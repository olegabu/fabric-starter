#!/usr/bin/env bash

export CONSORTIUM_CONFIG=InviteConsortiumPolicy
export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-open-net.yaml -f multihost.yaml"

./network-create-base.sh $@

