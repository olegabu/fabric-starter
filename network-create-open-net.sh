#!/usr/bin/env bash

source lib/util/util.sh

export CONSORTIUM_CONFIG=InviteConsortiumPolicy
export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-open-net.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml"
export DOMAIN=${DOMAIN:-example.com}

#use org1 host for hosting orderer either
first_org=${1:-org1}
shift

./network-create-base.sh $first_org $first_org:$first_org $@
