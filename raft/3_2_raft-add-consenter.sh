#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
#source $BASEDIR/../lib.sh
#source ../lib.sh 2>/dev/null # for IDE code completion

NEWCONSENTER_NAME=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_DOMAIN=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_PORT=${3:-7050}
NEWCONSENTER_WWW_PORT=${4:-80}

: ${DOMAIN:=example.com}
: ${ORDERER_DOMAIN:=${DOMAIN}}
: ${ORDERER_NAME:=orderer}
: ${DOCKER_COMPOSE_ORDERER_ARGS:="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml"}

export DOMAIN ORDERER_NAME ORDERER_DOMAIN

COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} EXECUTE_BY_ORDERER=1 docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer container-scripts/orderer/raft-add-orderer-msp.sh $NEWCONSENTER_NAME $NEWCONSENTER_DOMAIN ${NEWCONSENTER_WWW_PORT}
sleep 4
COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} EXECUTE_BY_ORDERER=1 docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer container-scripts/orderer/raft-add-consenter.sh $NEWCONSENTER_NAME $NEWCONSENTER_DOMAIN ${NEWCONSENTER_PORT} ${NEWCONSENTER_WWW_PORT}
sleep 4
COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${DOMAIN}  EXECUTE_BY_ORDERER=1 docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer container-scripts/orderer/raft-add-endpoint.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN} ${NEWCONSENTER_PORT}
sleep 4
