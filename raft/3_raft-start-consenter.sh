#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

REMOTE_WWW_ADDR=${1:?Remote www addr is requried}

: ${ORG:=org1}
: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=raft0}

docker rm -f ${ORDERER_NAME}.${DOMAIN}
docker volume rm -f ${ORDERER_NAME}${ORG}_orderer


ORDERER_NAME=${ORDERER_NAME} COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORG} EXECUTE_BY_ORDERER=1 runCLI "container-scripts/ops/raft-join-me.sh $REMOTE_WWW_ADDR"



COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORG} docker-compose -f docker-compose-orderer.yaml up -d orderer


