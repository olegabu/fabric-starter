#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

usageMsg="$0 channelName "
exampleMsg="$0 common "

channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

#echo "Create channel $ORG $channelName"
#downloadOrdererMSP ${ORDERER_NAME}
#set -x
#mkdir -p crypto-config/configtx
#envsubst < "templates/configtx-template.yaml" > "crypto-config/configtx.yaml"
#configtxgen -configPath crypto-config/ -outputCreateChannelTx crypto-config/configtx/channel_$channelName.tx -profile CHANNEL -channelID $channelName
#peer channel create -o ${ORDERER_NAME}.$ORDERER_DOMAIN:${ORDERER_GENERAL_LISTENPORT} -c $channelName -f crypto-config/configtx/channel_$channelName.tx --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt
##updateChannelModificationPolicy $channelName
#updateAnchorPeers "$channelName"
echo $DOMAIN

createChannel $channelName
