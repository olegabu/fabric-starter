#!/usr/bin/env bash
source lib.sh
usageMsg="$0  chaincodeName [version=1.0] [path to chaincode=/opt/chaincode/node/<chaincodeName>] [lang=node]"
exampleMsg="$0 reference 1.0 /opt/chaincode/node/reference node"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
version=${2-1.0}
path=${3-"/opt/chaincode/node/$chaincodeName"}
lang=${4-node}


installChaincode "$chaincodeName" "$path" "$lang" "$version"
