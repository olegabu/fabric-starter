#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib/util/util.sh
source ../lib/util/util.sh 2>/dev/null # for IDE code completion

usageMsg="ORG=<org name> ORDERER_NAME=<orderer instance name> $0"
exampleMsg="ORG=org1 ORDERER_NAME=raft0 $0"

: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=raft0}
: ${ORDERER_NAME_PREFIX:=raft}
: ${ORDERER_DOMAIN:=$DOMAIN}
: ${DOCKER_COMPOSE_ORDERER_ARGS:=-f docker-compose-orderer.yaml}
: ${WWW_PORT:=81}

export DOMAIN ORDERER_DOMAIN WWW_PORT

COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} ORDERER_NAME_PREFIX=${ORDERER_NAME_PREFIX} ORDERER_GENESIS_PROFILE=RaftOrdererGenesis docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d www.orderer cli.orderer

