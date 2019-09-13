#!/usr/bin/env bash
############################################################
#                  DEPRECATED
#               see inside-container scripts
############################################################
source lib.sh

: ${ORDERER_GENESIS_PROFILE:=SoloOrdererGenesis}

#[ -d "crypto-config/ordererOrganizations/$DOMAIN" ] && exit TODO: adjust for docker-machine
set -x
cryptogenTemplate="templates/cryptogen-orderer-template.yaml"
[ -f "templates/cryptogen-${ORDERER_GENESIS_PROFILE}-template.yaml" ] && cryptogenTemplate="templates/cryptogen-${ORDERER_GENESIS_PROFILE}-template.yaml"

EXECUTE_BY_ORDERER=1 envSubst "${cryptogenTemplate}" "crypto-config/cryptogen-orderer.yaml"
EXECUTE_BY_ORDERER=1 runCLI "rm -rf crypto-config/ordererOrganizations && cryptogen generate --config=crypto-config/cryptogen-orderer.yaml && chown $UID -R crypto-config/"

EXECUTE_BY_ORDERER=1 envSubst "templates/configtx-template.yaml" "crypto-config/configtx.yaml"
EXECUTE_BY_ORDERER=1 runCLI "mkdir -p crypto-config/configtx && configtxgen -configPath crypto-config/ -outputBlock crypto-config/configtx/genesis.pb -profile ${ORDERER_GENESIS_PROFILE} -channelID orderer-system-channel "

