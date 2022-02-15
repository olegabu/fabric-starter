#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib/util/util.sh
source ../lib/util/util.sh 2>/dev/null # for IDE code completion
source $BASEDIR/env.sh

usageMsg="ORG=<org name> ORDERER_NAME=<orderer instance name> $0"
exampleMsg="ORG=org1 ORDERER_NAME=raft0 $0"

: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=orderer}
: ${ORDERER_NAME_PREFIX:=raft}
: ${ORDERER_DOMAIN:=$DOMAIN}
: ${ORDERER_GENERAL_LISTENPORT:=${ORDERER_GENERAL_LISTENPORT:-7050}}

export DOMAIN ORDERER_NAME ORDERER_DOMAIN ORDERER_GENERAL_LISTENPORT

COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORDERER_DOMAIN} ORDERER_PROFILE=Raft docker-compose ${DOCKER_COMPOSE_ORDERER_ARGS} up -d --force-recreate www.orderer pre-install

