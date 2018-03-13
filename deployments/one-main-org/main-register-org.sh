#!/usr/bin/env bash

: ${FABRIC_STARTER_HOME:=../..}
source $FABRIC_STARTER_HOME/common.sh $1

newOrg=$2
newOrgIp=$3
channel=$4
chaincode=$5


###########################################################################
# Start
###########################################################################
network.sh -m register-new-org -o ${newOrg} -i ${newOrgIp} -k common


for channel in ${@:4}; do
  echo "Create channel $channel"
  network.sh -m create-channel $MAIN_ORG "$channel" ${newOrg}



done

echo -e $separateLine
read -n1 -r -p "On node'b' join to channel common (network.sh -m  join-channel b a common) Press any key to create channel a-b"
network.sh -m create-channel a "a-b" b

echo -e $separateLine
echo "Now chaincode 'chaincode_example02' will be installed and instantiated "
network.sh -m install-chaincode -o a -v 1.0 -n chaincode_example02
network.sh -m instantiate-chaincode -o a -k a-b -n chaincode_example02


echo -e $separateLine
read -n1 -r -p "On node 'b' join to channel 'a-b' then on node 'c' generate org c crypto (network.sh -m generate-peer -o c) and Press any key to register org c in channel common"
network.sh -m register-new-org -o b -i ${IP3} -k common



echo -e $separateLine
read -n1 -r -p "Press any key to create channel a-c and a-b-c"
network.sh -m create-channel a "a-c" c
network.sh -m create-channel a "a-b-c" b c

echo -e $separateLine
echo "Now on nodes 'b' and 'c' join to channels a-c and a-b-c correspondingly"


