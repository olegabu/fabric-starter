#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

REMOTE_WWW_ADDR=${1:?Remote www addr is requried}

: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=orderer}
: ${ORDERER_DOMAIN:=${DOMAIN}}
: ${ORDERER_GENERAL_LISTENPORT:=7050}
: ${ORDERER_NAME_PREFIX:=raft}
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml"}

export DOMAIN ORDERER_NAME ORDERER_DOMAIN ORDERER_GENERAL_LISTENPORT

COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} EXECUTE_BY_ORDERER=1 docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer container-scripts/ops/download-remote-config-block.sh $REMOTE_WWW_ADDR
sleep 1

echo "Start orderer ${ORDERER_NAME}.${ORDERER_DOMAIN} with new genesis"
COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d orderer cli.orderer #www.orderer


