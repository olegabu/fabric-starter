#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [args='[]' in form [\"funcName\", \"arg1\", \"arg2\"...]] "
exampleMsg="$0 common chaincode1 '[\"invoke\",\"a\"]' "

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
arguments=${3}
chaincodeVersion=${4}

invokeChaincode "$channelName" "$chaincodeName" "$arguments"