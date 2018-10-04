#!/usr/bin/env bash
source lib.sh
usageMsg="$0 newOrg channelName"
exampleMsg="$0 org2 common "

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
newOrg=${2:?`printUsage "$usageMsg" "$exampleMsg"`}

downloadMSP ${newOrg}
addOrgToChannel $channelName $newOrg