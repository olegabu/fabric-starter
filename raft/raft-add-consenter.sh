#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion


NEWCONSENTER_NAME=${1}
NEWCONSENTER_ORG=${2}
NEWCONSENTER_DOMAIN=${3:-${DOMAIN:-example.com}}

: ${ORG:=org1}
: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=raft0}

COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORG}.${DOMAIN}  EXECUTE_BY_ORDERER=1 runCLI "container-scripts/ops/raft-add-consenter.sh $NEWCONSENTER_NAME ${NEWCONSENTER_ORG} $NEWCONSENTER_DOMAIN"

