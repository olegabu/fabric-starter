#!/usr/bin/env bash

: ${FABRIC_STARTER_HOME:=../..}
source $FABRIC_STARTER_HOME/common.sh $1 $2

network.sh -m down
docker rm -f $(docker ps -aq)
docker ps -a

###########################################################################
# Start
###########################################################################
network.sh -m generate-peer -o $THIS_ORG

echo -e $separateLine
read -n1 -r -p "Peer material is generated. Now on node 'a' add org 'b' then press any key in this console to start UP org b..."
network.sh -m add-org-connectivity -o $THIS_ORG -M $MAIN_ORG -i ${IP1}
network.sh -m up-one-org -o $THIS_ORG -M $MAIN_ORG

echo -e $separateLine
read -n1 -r -p "Press any key to join org b to channel common"
network.sh -m  join-channel $THIS_ORG $MAIN_ORG common

echo -e $separateLine
echo "Chaincode 'chaincode_example02' will be installed"
network.sh -m install-chaincode -o $THIS_ORG -v 1.0 -n chaincode_example02

echo -e $separateLine
read -n1 -r -p "Create channel a-b on node a and press any key to join org b to channel a-b"
network.sh -m  join-channel $THIS_ORG $MAIN_ORG a-b

echo -e $separateLine
read -n1 -r -p "Make steps on nodes 'c' and 'a' to add org c then press any key to refresh b's api"
network.sh -m restart-api -o $THIS_ORG


