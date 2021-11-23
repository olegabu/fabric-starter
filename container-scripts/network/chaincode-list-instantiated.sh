#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh 2>/dev/null
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

#usageMsg="$0 channelName chaincodeName [init args='[]'] [version=1.0] [privateCollectionPath] [endorsementPolicy]"
#exampleMsg="$0 common chaincode1 '[\"Init\",\"a\",\"10\", \"b\", \"0\"]'"

channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

listChaincodesInstantiated $channelName