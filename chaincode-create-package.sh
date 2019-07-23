#!/usr/bin/env bash
source lib.sh
usageMsg="$0 chaincode-path chaincode-package-name"
exampleMsg="$0 /opt/chaincode/java/reference reference.cds"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodePath=${2:?Chaincode path must be specified}
chaincodeLang=${3:?Chaincode lang must be specified}
chaincodeVersion=${4:?Chaincode version must be specified}
chaincodePackageName=${5:?Chaincode PackageName must be specified}


createChaincodePackage "$chaincodeName" "$chaincodePath" "$chaincodeLang" "$chaincodeVersion" "$chaincodePackageName"