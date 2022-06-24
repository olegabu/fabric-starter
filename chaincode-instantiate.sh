#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [version=1.0] [init args='[]'] [privateCollectionPath] [endorsementPolicy]"
exampleMsg="$0 common chaincode1 1.0 '[\"Init\",\"a\",\"10\", \"b\", \"0\"]'"

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
initArguments=${3}
chaincodeVersion=${4-1.0}
privateCollectionPath=${5}
endorsementPolicy=${6}
envConfig=${7:-${ORG:-org}}

source ${envConfig}_env
: ${PEER0_PORT:=7051}

#ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/chaincode-instantiate.sh $channelName $chaincodeName '$initArguments' $chaincodeVersion $privateCollectionPath $endorsementPolicy"

COMPOSE_PROJECT_NAME=${ORG} docker-compose exec cli.peer container-scripts/network/chaincode-instantiate.sh $channelName $chaincodeName "$initArguments" $chaincodeVersion $privateCollectionPath $endorsementPolicy
