#!/usr/bin/env bash

source lib.sh

EXECUTE_BY_ORDERER=1 runCLI "rm -rf crypto-config/ordererOrganizations \
&& envsubst <templates/cryptogen-orderer-template.yaml >crypto-config/cryptogen-orderer.yaml \
&& cryptogen generate --config=crypto-config/cryptogen-orderer.yaml"

EXECUTE_BY_ORDERER=1 runCLI "mkdir -p crypto-config/configtx \
&& envsubst <templates/configtx-genesis-template.yaml >crypto-config/configtx.yaml \
&& configtxgen -configPath crypto-config/ -outputBlock crypto-config/configtx/genesis.pb -profile OrdererGenesis -channelID orderer-system-channel"

