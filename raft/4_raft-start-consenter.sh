#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

REMOTE_WWW_ADDR=${1:?Remote www addr is requried}

: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=raft0}
: ${ORDERER_GENERAL_LISTENPORT:=7050}
: ${DOCKER_COMPOSE_ORDERER_ARGS:= -f docker-compose-orderer.yaml}


echo "Stop orderer ${ORDERER_NAME}.${DOMAIN}"
COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${DOMAIN} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} down -v

ORDERER_NAME=${ORDERER_NAME} COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${DOMAIN} EXECUTE_BY_ORDERER=1 runCLI "container-scripts/ops/raft-download-remote-config-block.sh $REMOTE_WWW_ADDR"

echo "Start orderer ${ORDERER_NAME}.${DOMAIN} with new genesis"
COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${DOMAIN} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer


