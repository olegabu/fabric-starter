#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-org> <new-consenter-domain> <new-consenter-port>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0"

: ${DOMAIN:=example.com}
: ${ORDERER_NAME_PREFIX:=raft}
: ${DOCKER_COMPOSE_ORDERER_ARGS:= -f docker-compose-orderer.yaml}

echo "Start first Raft node 0"
ORDERER_GENESIS_PROFILE=Raft3OrdererGenesis COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}0.${DOMAIN} ORDERER_NAME=${ORDERER_NAME_PREFIX}0 docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer cli.orderer www.orderer
sleep 5
echo "Start first Raft node 1"
COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}1.${DOMAIN} ORDERER_GENERAL_LISTENPORT=${RAFT1_PORT} ORDERER_NAME=${ORDERER_NAME_PREFIX}1 docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer
sleep 5
echo "Start first Raft node 2"
COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}2.${DOMAIN} ORDERER_GENERAL_LISTENPORT=${RAFT2_PORT} ORDERER_NAME=${ORDERER_NAME_PREFIX}2 docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer
sleep 5

