#!/usr/bin/env bash
source lib.sh
usageMsg="$0  chaincodeName [version=1.0] [path to chaincode=/opt/chaincode/node/<chaincodeName>] [lang=node]"
exampleMsg="$0 reference 1.0 /opt/chaincode/node/reference node"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
version=${2-1.0}
path=${3-"/opt/chaincode/node/$chaincodeName"}
lang=${4-node}
envConfig=${5:-${ORG:-org}}

source ${envConfig}_env
: ${PEER0_PORT:=7051}

#ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/chaincode-install.sh $chaincodeName $version $path $lang"

COMPOSE_PROJECT_NAME=${ORG} docker-compose exec cli.peer container-scripts/network/chaincode-install.sh $chaincodeName $version $path $lang
