#!/usr/bin/env bash
source lib.sh
usageMsg="$0 chaincodeName channelName [args='[]']"
exampleMsg="$0 chaincode1 common '[\"invoke\",\"a\"]'"

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
arguments=${3-'[]'}

invokeChaincode "$channelName" "$chaincodeName" "$arguments"
