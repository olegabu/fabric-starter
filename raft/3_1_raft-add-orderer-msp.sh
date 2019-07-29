#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

NEWCONSENTER_NAME=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_DOMAIN=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_PORT=${3:-7050}
NEWCONSENTER_WWW_PORT=${4:-80}

: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=raft0}

COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${DOMAIN} EXECUTE_BY_ORDERER=1 runCLI "container-scripts/orderer/raft-add-orderer-msp.sh $NEWCONSENTER_NAME $NEWCONSENTER_DOMAIN ${NEWCONSENTER_WWW_PORT}"

