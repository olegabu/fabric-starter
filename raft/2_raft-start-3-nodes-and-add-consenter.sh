#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-domain>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0"


: ${ORG:=org1}
: ${DOMAIN:=example.com}
: ${ORDERER_NAME_PREFIX:=raft}

#IFS=
NEWCONSENTER_NAME=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_ORG=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_DOMAIN=${3:?`printUsage "$usageMsg" "$exampleMsg"`}

ORDERER_GENESIS_PROFILE=Raft3OrdererGenesis COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}0.${ORG}.${DOMAIN} ORDERER_NAME=${ORDERER_NAME_PREFIX}0 docker-compose -f docker-compose-orderer.yaml up -d
sleep 5
COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}1.${ORG}.${DOMAIN} ORDERER_NAME=${ORDERER_NAME_PREFIX}1 docker-compose -f docker-compose-orderer.yaml up -d orderer
sleep 5
COMPOSE_PROJECT_NAME=${ORDERER_NAME_PREFIX}2.${ORG}.${DOMAIN} ORDERER_NAME=${ORDERER_NAME_PREFIX}2 docker-compose -f docker-compose-orderer.yaml up -d orderer
sleep 5

sleep 20
ORDERER_NAME=${ORDERER_NAME_PREFIX}0 $BASEDIR/raft-add-consenter.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_ORG} ${NEWCONSENTER_DOMAIN}


DOMAIN=${DOMAIN} COMPOSE_PROJECT_NAME=${ORG}.${DOMAIN} docker-compose up -d

