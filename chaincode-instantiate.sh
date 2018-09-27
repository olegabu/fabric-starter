#!/usr/bin/env bash
source lib.sh
usageMsg="$0 chaincodeName channelName [init args='[]'] [version=1.0]"
exampleMsg="$0 chaincode1 common '[\"Init\",\"a\",\"10\", \"b\", \"0\"]'"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
channelName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
initArguments=${3-'[]'}
chaincodeVersion=${4-1.0}
path=${5:-''}
collection=${6}


instantiateChaincode "$channelName" "$chaincodeName" "$initArguments" "$chaincodeVersion" "$path" "$collection"
