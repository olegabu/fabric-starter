#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [init args='[]'] [version=1.0] [privateCollectionPath] [endorsementPolicy='ANY']"
exampleMsg="$0 common chaincode1 '[\"Init\",\"arg1\",\"val1\"]' 2.0 "" \"OR ('org1.member', 'org2.member')\""

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
initArguments=${3:-'[]'}
chaincodeVersion=${4}
privateCollectionPath=${5}
endorsementPolicy=${6}

: ${PEER0_PORT:=7051}

ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/chaincode-upgrade.sh $channelName $chaincodeName '$initArguments' $chaincodeVersion \"$privateCollectionPath\" $endorsementPolicy"
