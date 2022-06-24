#!/usr/bin/env bash
source lib.sh
usageMsg="$0  chaincode-package-file-name"
exampleMsg="$0 reference.tar.gz"

IFS=
chaincodePackage=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
envConfig=${5:-${ORG:-org}}

source ${envConfig}_env
: ${PEER0_PORT:=7051}

#ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/chaincode-install-package.sh $chaincodeName"
COMPOSE_PROJECT_NAME=${ORG} docker-compose exec cli.peer container-scripts/network/chaincode-install-package.sh $chaincodePackage
