#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

channelName=${1:?Channel name is required}
chaincodeName=${2:?Chaincode name is required}
arguments=${3-'[]'}

invokeChaincode "$channelName" "$chaincodeName" "$arguments"