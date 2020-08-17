#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_DOMAIN=${2}
NEWCONSENTER_PORT=${3:-7050}
NEWCONSENTER_WWW_PORT=${4:-80}


$BASEDIR/raft-add-orderer-msp.sh $NEWCONSENTER_NAME $NEWCONSENTER_DOMAIN ${NEWCONSENTER_WWW_PORT}
$BASEDIR/raft-add-consenter.sh $NEWCONSENTER_NAME $NEWCONSENTER_DOMAIN ${NEWCONSENTER_PORT} ${NEWCONSENTER_WWW_PORT}
$BASEDIR/raft-add-endpoint.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN} ${NEWCONSENTER_PORT}