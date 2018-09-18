#!/usr/bin/env bash
source lib.sh

channelName=${1:?"Channel channel name must be specified"}
[ -z "$ORG" ] && echo "ORG environmet variable should be set" && exit 1

echo "Create channel $ORG $channelName"
downloadMSP orderer
runCLI "mkdir -p crypto-config/configtx \
    && envsubst <templates/configtx-channel-template.yaml >crypto-config/configtx.yaml \
    && configtxgen -configPath crypto-config/ -outputCreateChannelTx crypto-config/configtx/channel_$channelName.tx -profile CHANNEL -channelID $channelName \
    && peer channel create -o orderer.$DOMAIN:7050 -c $channelName -f crypto-config/configtx/channel_$channelName.tx --tls --cafile /etc/hyperledger/crypto/orderer/tls/ca.crt"
updateChannelModificationPolicy $channelName
