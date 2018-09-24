#!/usr/bin/env bash
source lib.sh
usageMsg="$0  chaincodeName [path to chaincode=<chaincodeName>] [lang=golang] [version=1.0]"
exampleMsg="$0 reference /opt/chaincode/node/reference node"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
path=${2-"/opt/chaincode/node/$chaincodeName"}
lang=${3-node}
version=${4-1.0}

installChaincode "$chaincodeName" "$path" "$lang" "$version"