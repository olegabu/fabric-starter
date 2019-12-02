#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-org> <new-consenter-domain> <new-consenter-port>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0"

: ${ORDERER_DOMAIN:-${DOMAIN:=example.com}}
: ${ORDERER_NAME:=orderer}
: ${ORDERER_NAME_2:=raft1}
: ${ORDERER_NAME_3:=raft2}
: ${RAFT_NODES_COUNT:=3}
: ${ORDERER_PROFILE:=Raft}
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml"}

export DOMAIN ORDERER_DOMAIN WWW_PORT RAFT_NODES_COUNT

echo "Start first Raft node 0 (orderer.$DOMAIN)"
ORDERER_PROFILE=${ORDERER_PROFILE} COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${DOMAIN} ORDERER_GENERAL_LISTENPORT=${RAFT0_PORT:-7050} ORDERER_NAME=${ORDERER_NAME} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer cli.orderer www.orderer
sleep 8
echo "Start first Raft node 1"
ORDERER_OPERATIONS_LISTENADDRESS=0.0.0.0:9091 COMPOSE_PROJECT_NAME=${ORDERER_NAME_2}.${DOMAIN} ORDERER_GENERAL_LISTENPORT=${RAFT1_PORT:-7150} ORDERER_NAME=${ORDERER_NAME_2} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d --no-deps orderer
echo "Start first Raft node 2"
ORDERER_OPERATIONS_LISTENADDRESS=0.0.0.0:9092 COMPOSE_PROJECT_NAME=${ORDERER_NAME_3}.${DOMAIN} ORDERER_GENERAL_LISTENPORT=${RAFT2_PORT:-7250} ORDERER_NAME=${ORDERER_NAME_3} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d --no-deps orderer


