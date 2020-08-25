#!/usr/bin/env bash

export FABRIC_STARTER_HOME=${FABRIC_STARTER_HOME:-./}              # path to fabric-starter folder

export DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS:-"-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}

export RAFT0_PORT=${RAFT0_PORT:-7050} \
       RAFT1_PORT=${RAFT1_PORT:-7150} \
       RAFT2_PORT=${RAFT2_PORT:-7250}

export ORG2_RAFT_NAME_1=raft3 \
       ORG2_RAFT_NAME_2=raft4 \
       ORG2_RAFT_NAME_3=raft5