#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [init args='{}'] [version=1.0] [endorsementPolicy='ANY']"
exampleMsg="$0 common chanicode1 '{\"Args\":[\"Init\",\"arg1\",\"val1\"]}' 2.0 \"OR ('org1.member', 'org2.member')\""

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
initArguments=${3}
chaincodeVersion=${4}

upgradeChaincode "$channelName" "$chaincodeName" "$initArguments" "$chaincodeVersion"