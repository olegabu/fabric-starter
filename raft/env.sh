#!/usr/bin/env bash

export ORDERER_DOMAIN=example.com

export WORK_DIR=./              # path to fabric-starter folder

export DOCKER_COMPOSE_ORDERER_ARGS="-f docker-compose-orderer.yaml -f docker-compose-orderer-multihost.yaml"

export RAFT0_PORT=7050 \
       RAFT1_PORT=7150 \
       RAFT2_PORT=7250

export ORG2_RAFT_NAME_1=raft3 \
       ORG2_RAFT_NAME_2=raft4 \
       ORG2_RAFT_NAME_3=raft5