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
network.sh -m register-new-org -o ${newOrg} -M $MAIN_ORG -i ${newOrgIp} -k "common necommon"


for channel in ${@:4}; do
  echo "Create channel $channel"
  network.sh -m create-channel $MAIN_ORG "$channel" ${newOrg}
done


#echo -e $separateLine
#echo "Now chaincode 'chaincode_example02' will be installed and instantiated "
#network.sh -m install-chaincode -o a -v 1.0 -n chaincode_example02
#network.sh -m instantiate-chaincode -o a -k a-b -n chaincode_example02




