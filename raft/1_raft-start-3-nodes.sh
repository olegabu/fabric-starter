#!/usr/bin/env bash

BASEDIR=$(dirname "$0")
source $BASEDIR/../lib.sh
source ../lib.sh 2>/dev/null # for IDE code completion
source $BASEDIR/env.sh

usageMsg="ORG=org ORDERER_NAME_PREFIX=<orderer name prefix> $0 <new-consenter-name> <new-consenter-org> <new-consenter-domain> <new-consenter-port>"
exampleMsg="ORG=org1 ORDERER_NAME_PREFIX=raft0 $0"

: ${ORDERER_DOMAIN:=${DOMAIN:-example.com}}
: ${ORDERER_NAME:=${ORDERER_NAME_0:-orderer}}
: ${ORDERER_NAME_1:=raft1}
: ${ORDERER_NAME_2:=raft2}
: ${RAFT_NODES_COUNT:=3}
: ${ORDERER_PROFILE:=Raft}

export DOMAIN ORDERER_DOMAIN WWW_PORT RAFT_NODES_COUNT

echo "Start first Raft node 0 (orderer.$DOMAIN)"
RAFT_NODES_COUNT=${RAFT_NODES_COUNT} ORDERER_GENERAL_LISTENPORT=${RAFT0_PORT:-${ORDERER_GENERAL_LISTENPORT:-7050}} ORDERER_NAME=${ORDERER_NAME} ./$BASEDIR/0_raft-start-1-node.sh
sleep 8
echo "Start Raft node 1"
ORDERER_OPERATIONS_LISTENADDRESS=0.0.0.0:9091 ORDERER_GENERAL_LISTENPORT=${RAFT1_PORT:-7150} ORDERER_NAME=${ORDERER_NAME_1} ./$BASEDIR/0_raft-start-1-node.sh --no-deps orderer
echo "Start Raft node 2"
ORDERER_OPERATIONS_LISTENADDRESS=0.0.0.0:9092 ORDERER_GENERAL_LISTENPORT=${RAFT2_PORT:-7250} ORDERER_NAME=${ORDERER_NAME_2} ./$BASEDIR/0_raft-start-1-node.sh --no-deps orderer


