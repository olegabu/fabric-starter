#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion

usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-org> <new-consenter-domain> <new-consenter-port>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0 raft0 org example2.com 7150"


NEWCONSENTER_NAME=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_ORG=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_DOMAIN=${3:?`printUsage "$usageMsg" "$exampleMsg"`}
NEWCONSENTER_PORT=${4:-7050}

: ${ORG:=org1}
: ${DOMAIN:=example.com}
: ${ORDERER_NAME:=raft0}


COMPOSE_PROJECT_NAME=${ORDERER_NAME}.${ORG}.${DOMAIN}  EXECUTE_BY_ORDERER=1 runCLI "container-scripts/ops/raft-add-endpoint.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_ORG} ${NEWCONSENTER_DOMAIN} ${NEWCONSENTER_PORT}"