#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName "
exampleMsg="$0 common "

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}

echo "Create channel $ORG $channelName"
downloadMSP
runCLI "mkdir -p crypto-config/configtx"
envSubst "templates/configtx-template.yaml" "crypto-config/configtx.yaml"
runCLI "configtxgen -configPath crypto-config/ -outputCreateChannelTx crypto-config/configtx/channel_$channelName.tx -profile CHANNEL -channelID $channelName \
    && peer channel create -o orderer.$DOMAIN:7050 -c $channelName -f crypto-config/configtx/channel_$channelName.tx --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
#updateChannelModificationPolicy $channelName
updateAnchorPeers "$channelName"
