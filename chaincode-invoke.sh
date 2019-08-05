#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [args='[]']"
exampleMsg="$0 common reference '[\"put\",\"a\"]'"

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
arguments=${3-'[]'}

: ${PEER0_PORT:=7051}

ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/chaincode-invoke.sh  $channelName $chaincodeName '$arguments'"
