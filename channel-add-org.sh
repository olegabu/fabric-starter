#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName newOrg"
exampleMsg="$0 common org2"

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
newOrg=${2:?`printUsage "$usageMsg" "$exampleMsg"`}

#downloadMSP ${newOrg}
#addOrgToChannel $channelName $newOrg

ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} runCLI "container-scripts/network/channel-add-org.sh $channelName ${newOrg}"