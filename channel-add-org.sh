#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName newOrg"
exampleMsg="$0 common org2"

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
newOrg=${2:?`printUsage "$usageMsg" "$exampleMsg"`}
newOrgPeer0Port=${3:-7051}
newOrgWwwPort=${4:-80}
newOrgDomain=${5:-$DOMAIN}

#downloadMSP ${newOrg}
#addOrgToChannel $channelName $newOrg

ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN} runCLI "container-scripts/network/channel-add-org.sh $channelName ${newOrg} ${newOrgPeer0Port} ${newOrgWwwPort} ${newOrgDomain}"