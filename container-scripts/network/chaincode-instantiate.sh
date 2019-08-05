#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

usageMsg="$0 channelName chaincodeName [init args='[]'] [version=1.0] [privateCollectionPath] [endorsementPolicy]"
exampleMsg="$0 common chaincode1 '[\"Init\",\"a\",\"10\", \"b\", \"0\"]'"

channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
initArguments=${3-'[]'}
chaincodeVersion=${4-1.0}
privateCollectionPath=${5}
endorsementPolicy=${6}

instantiateChaincode "$channelName" "$chaincodeName" "$initArguments" "$chaincodeVersion" "$privateCollectionPath" "$endorsementPolicy"
