#!/usr/bin/env /bin/bash

#BASEDIR=$(dirname "$0")
#source $BASEDIR/env.sh

usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-org> <new-consenter-domain> <new-consenter-port>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0"

: ${NO_DEPS:=${1}}
: ${SERVICE:=${2}}
: ${ORDERER_DOMAIN:=${DOMAIN:-example.com}}
: ${ORDERER_NAME:=${ORDERER_NAME_0:-orderer}}
: ${CONSENTER_ID:=${CONSENTER_ID:-1}}
: ${ORDERER_NAMES:=${ORDERER_NAME:-orderer}}
: ${RAFT_NODES_COUNT:=1}
: ${ORDERER_PROFILE:=Raft}
: ${ORDERER_OPERATIONS_LISTENADDRESS:=0.0.0.0:9090}
export FABRIC_STARTER_HOME=${FABRIC_STARTER_HOME:-./}              # path to fabric-starter folder
export DOCKER_COMPOSE_ORDERER_ARGS=${DOCKER_COMPOSE_ORDERER_ARGS:-"-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"}

export DOMAIN ORDERER_DOMAIN WWW_PORT RAFT_NODES_COUNT

echo "Start Raft node $ORDERER_NAME.$DOMAIN"
ORDERER_PROFILE=${ORDERER_PROFILE} COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} \
    ORDERER_GENERAL_LISTENPORT=${ORDERER_GENERAL_LISTENPORT:-7050} ORDERER_NAME=${ORDERER_NAME} \
    ORDERER_OPERATIONS_LISTENADDRESS=${ORDERER_OPERATIONS_LISTENADDRESS} CONSENTER_ID=${CONSENTER_ID} \
    docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d ${NO_DEPS} ${SERVICE} #orderer cli.orderer www.orderer
