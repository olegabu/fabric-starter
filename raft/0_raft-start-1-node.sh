#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion
source $BASEDIR/env.sh

usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-org> <new-consenter-domain> <new-consenter-port>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0"

: ${ORDERER_DOMAIN:=${DOMAIN:-example.com}}
: ${ORDERER_NAME:=${ORDERER_NAME_0:-orderer}}
: ${RAFT_NODES_COUNT:=1}
: ${ORDERER_PROFILE:=Raft}
: ${ORDERER_OPERATIONS_LISTENADDRESS:=0.0.0.0:9090}
: ${NO_DEPS:=${1}}
: ${SERVICE:=${2}}

export DOMAIN ORDERER_DOMAIN WWW_PORT RAFT_NODES_COUNT

echo "Start Raft node $ORDERER_NAME.$DOMAIN"
ORDERER_PROFILE=${ORDERER_PROFILE} COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} \
    ORDERER_GENERAL_LISTENPORT=${ORDERER_GENERAL_LISTENPORT:-7050} ORDERER_NAME=${ORDERER_NAME} \
    ORDERER_OPERATIONS_LISTENADDRESS=${ORDERER_OPERATIONS_LISTENADDRESS} \
    docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d ${NO_DEPS} ${SERVICE} #orderer cli.orderer www.orderer
