#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [init args='[]' as [\"Init\", \"arg1\", \"arg2\"...]] [version=1.0]"
exampleMsg="$0 common chanicode1 '[\"Init\",\"a\",\"10\", \"b\", \"0\"]'"

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
initArguments=${3}
chaincodeVersion=${4}

instantiateChaincode "$channelName" "$chaincodeName" "$initArguments" "$chaincodeVersion"
