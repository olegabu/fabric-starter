#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
#source $BASEDIR/../lib.sh
#source ../lib.sh 2>/dev/null # for IDE code completion
source $BASEDIR/env.sh

NEWCONSENTER_NAME=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_DOMAIN=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_IP=${3:?New consenter ip is required}
NEWCONSENTER_PORT=${4:-7050}
NEWCONSENTER_WWW_PORT=${5:-80}

: ${DOMAIN:=example.com}
: ${ORDERER_DOMAIN:=${DOMAIN}}
: ${ORDERER_NAME:=orderer}

export DOMAIN ORDERER_NAME ORDERER_DOMAIN

export COMPOSE_PROJECT_NAME=${NEWCONSENTER_NAME}.${ORDERER_DOMAIN} EXECUTE_BY_ORDERER=1

docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer bash -c "echo -e '${NEWCONSENTER_IP}\t${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN} www.${NEWCONSENTER_DOMAIN}' >> /etc/hosts"
sleep 1
docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer container-scripts/orderer/raft-add-orderer-msp.sh $NEWCONSENTER_NAME $NEWCONSENTER_DOMAIN ${NEWCONSENTER_WWW_PORT}
sleep 2
docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer container-scripts/orderer/raft-add-consenter.sh $NEWCONSENTER_NAME $NEWCONSENTER_DOMAIN ${NEWCONSENTER_PORT} ${NEWCONSENTER_WWW_PORT}
sleep 2
EXECUTE_BY_ORDERER=1 docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} run --no-deps cli.orderer container-scripts/orderer/raft-add-endpoint.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN} ${NEWCONSENTER_PORT}
sleep 2

