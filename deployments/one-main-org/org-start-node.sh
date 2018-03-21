#!/usr/bin/env bash

###########################################################################
# Start
###########################################################################
echo "Start org"
network.sh -m add-org-connectivity -o $THIS_ORG -M $MAIN_ORG -R $MAIN_ORG -i ${IP1}
network.sh -m up-one-org -o $THIS_ORG -M $MAIN_ORG


echo -e $separateLine
echo "Joining org $THIS_ORG to channel common"
network.sh -m  join-channel $THIS_ORG $MAIN_ORG common

#join bilateral with main
channelWithMainOrg="${MAIN_ORG}-${THIS_ORG}"
echo "Joining org $THIS_ORG to channel $channelWithMainOrg"
network.sh -m join-channel $THIS_ORG $MAIN_ORG "$channelWithMainOrg"


./install-cc.sh




