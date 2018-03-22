#!/usr/bin/env bash

newOrg=$1
newOrgIp=$2
existingOrg=$3

###########################################################################
# Start
###########################################################################
channels="common"

#bilateral channel with main org
channelWithMainOrg="${MAIN_ORG}-${newOrg}"
echo "Creating bilateral channel $channelWithMainOrg"
#create bilateral channel with main prg
network.sh -m create-channel $MAIN_ORG "$channelWithMainOrg"
#update policy for channel before adding other orgs
network.sh -m update-sign-policy -o $THIS_ORG -k "$channelWithMainOrg"
#instantiate  chaincode in bilateral channel with main org
network.sh -m instantiate-chaincode -o $THIS_ORG -k $channelWithMainOrg -n chaincode_example02 -I "${CHAINCODE_COMMON_INIT}"
network.sh -m warmup-chaincode -o $THIS_ORG -k $channelWithMainOrg -n chaincode_example02 -I "${CHAINCODE_QUERY_ARG}"

#track channels list
channels="$channels ${channelWithMainOrg}"



if [[ -n "$existingOrg" ]]; then
    channelWithExisting="$existingOrg-$newOrg"
    echo "Create bilateral channel: $channelWithExisting"
    network.sh -m create-channel $MAIN_ORG "$channelWithExisting"
    #update policy for channel before adding other orgs
    network.sh -m update-sign-policy -o $THIS_ORG -k "$channelWithExisting"
    #register exisiting org in new channel
    network.sh -m register-org-in-channel $MAIN_ORG "$channelWithExisting" ${existingOrg}
    #instantiate  chaincodes in bilateral with main org channel
    network.sh -m instantiate-chaincode -o $THIS_ORG -k $channelWithExisting -n chaincode_example02 -I "${CHAINCODE_COMMON_INIT}"
    network.sh -m warmup-chaincode -o $THIS_ORG -k $channelWithExisting -n chaincode_example02 -I "${CHAINCODE_QUERY_ARG}"

    #track channels list
    channels="$channels ${channelWithExisting}"
fi

echo "***************************************************************************"
echo "Register new org in channels: $channels"
#create new org and register in all channels
network.sh -m register-new-org -o ${newOrg} -M $MAIN_ORG -i ${newOrgIp} -k "$channels"
