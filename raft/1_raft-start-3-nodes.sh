#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-org> <new-consenter-domain> <new-consenter-port>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0"

: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=orderer}
: ${ORDERER_NAME_2:=raft1}
: ${ORDERER_NAME_3:=raft2}
: ${RAFT_NODES_COUNT:=3}
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml"}

export DOMAIN WWW_PORT RAFT_NODES_COUNT

echo "Start first Raft node 0 (orderer.$DOMAIN)"
ORDERER_GENESIS_PROFILE=Raft3OrdererGenesis COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${DOMAIN} ORDERER_GENERAL_LISTENPORT=${RAFT0_PORT:-7050} ORDERER_NAME=${ORDERER_NAME} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer cli.orderer www.orderer
sleep 5
echo "Start first Raft node 1"
COMPOSE_PROJECT_NAME=${ORDERER_NAME_2}.${DOMAIN} ORDERER_GENERAL_LISTENPORT=${RAFT1_PORT:-7050} ORDERER_NAME=${ORDERER_NAME_2} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer
sleep 5
echo "Start first Raft node 2"
COMPOSE_PROJECT_NAME=${ORDERER_NAME_3}.${DOMAIN} ORDERER_GENERAL_LISTENPORT=${RAFT2_PORT:-7050} ORDERER_NAME=${ORDERER_NAME_3} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer
sleep 5

