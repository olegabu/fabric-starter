#!/usr/bin/env bash
source lib.sh
usageMsg="$0 newOrg channelName"
exampleMsg="$0 org2 common "

IFS=
newOrg=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
channelName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}

addOrgToChannel $newOrg $channelName