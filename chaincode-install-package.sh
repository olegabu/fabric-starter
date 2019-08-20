#!/usr/bin/env bash
source lib.sh
usageMsg="$0  chaincode-package-file-name"
exampleMsg="$0 reference.cds"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

: ${PEER0_PORT:=7051}

ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/chaincode-install-package.sh $chaincodeName"