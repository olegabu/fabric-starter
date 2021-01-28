#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [args='[]']"
exampleMsg="$0 common chaincode1 '[\"query\",\"a\"]' "

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
arguments=${3-'[]'}

: ${PEER0_PORT:=7051}

ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/chaincode-query.sh $channelName $chaincodeName '$arguments'"
