#!/usr/bin/env bash

source lib.sh

run "rm -rf crypto-config/ordererOrganizations \
&& sed -e 's/DOMAIN/$DOMAIN/g' templates/cryptogen-orderer-template.yaml > crypto-config/cryptogen-orderer.yaml \
&& cryptogen generate --config=crypto-config/cryptogen-orderer.yaml"

run "mkdir -p crypto-config/configtx \
&& sed -e 's/DOMAIN/$DOMAIN/g' templates/configtx-genesis-template.yaml > crypto-config/configtx.yaml \
&& configtxgen --configPath /crypto-config -outputBlock /crypto-config/configtx/genesis.pb -profile OrdererGenesis -channelID orderer-system-channel"
