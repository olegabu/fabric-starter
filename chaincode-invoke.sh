#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [args='[]']"
exampleMsg="$0 common reference '[\"put\",\"a\"]'"

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
arguments=${3-'[]'}

invokeChaincode "$channelName" "$chaincodeName" "$arguments"