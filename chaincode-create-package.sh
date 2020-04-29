#!/usr/bin/env bash
source lib.sh
usageMsg="$0 chaincode-path chaincode-package-name chaincode-lang chaincode-ver chaincode-pack-file-name"
exampleMsg="$0 /opt/chaincode/java/reference reference node 1.0 reference.cds"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodePath=${2:?Chaincode path must be specified}
chaincodeLang=${3:?Chaincode lang must be specified}
chaincodeVersion=${4:?Chaincode version must be specified}
chaincodePackageName=${5:?Chaincode PackageName must be specified}

ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} ORDERER_NAME=${ORDERER_NAME} runCLI "container-scripts/network/chaincode-create-package.sh $chaincodeName $chaincodePath $chaincodeLang $chaincodeVersion $chaincodePackageName"
