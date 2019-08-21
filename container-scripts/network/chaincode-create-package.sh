#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
path=${2-"/opt/chaincode/$chaincodeName"}
lang=${3-node}
version=${4-1.0}
packageName=${5-some.cds}

env|sort
createChaincodePackage "$chaincodeName" "$path" "$lang" "$version" "$packageName"