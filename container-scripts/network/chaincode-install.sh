#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
version=${2-1.0}
path=${3-"/opt/chaincode/node/$chaincodeName"}
lang=${4-node}

set -x
installChaincode "$chaincodeName" "$path" "$lang" "$version"
