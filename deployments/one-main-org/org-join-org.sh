#!/usr/bin/env bash

externalOrg=$1
externalOrgIp=$2
channelName=$3

###########################################################################
# Start
###########################################################################

#join bilateral channels
echo "Join channel: $channelName"
network.sh -m  join-channel $THIS_ORG $MAIN_ORG "$channelName"


#add peers' record for external org to api's /etc/hosts
network.sh -m add-org-connectivity -o $THIS_ORG -M $MAIN_ORG -R $externalOrg -i $externalOrgIp

