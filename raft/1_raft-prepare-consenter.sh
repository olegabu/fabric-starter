#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib/util/util.sh
source ../lib/util/util.sh 2>/dev/null # for IDE code completion

usageMsg="ORG=<org name> ORDERER_NAME=<orderer instance name> $0"
exampleMsg="ORG=org1 ORDERER_NAME=raft0 $0"


: ${ORG:=org1}
: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=raft0}

COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORG}.${DOMAIN} ORDERER_GENESIS_PROFILE=Raft3OrdererGenesis docker-compose -f docker-compose-orderer.yaml up -d post-install

sleep 2

DOMAIN=${DOMAIN} COMPOSE_PROJECT_NAME=${ORG}.${DOMAIN} docker-compose up -d