#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null
echo $@
REMOTE_WWW_ADDR=${1:?Remote orderer www is required}
SYSTEM_CHANNEL=${2:-${SYSTEM_CHANNEL_ID}}
ORDERER_DOMAIN=${ORDERER_DOMAIN:-$DOMAIN}

wget ${WGET_OPTS} -P crypto-config/configtx http://${REMOTE_WWW_ADDR}/msp/${ORDERER_NAME}.${ORDERER_DOMAIN}/genesis/${SYSTEM_CHANNEL}_remote.pb
cp crypto-config/configtx/${SYSTEM_CHANNEL}_remote.pb crypto-config/configtx/${ORDERER_DOMAIN}/genesis.pb







