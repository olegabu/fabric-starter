#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null
echo $@
REMOTE_ORDERER_ADDR=${1}
SYSTEM_CHANNEL=${2:-${SYSTEM_CHANNEL_ID}}

wget ${WGET_OPTS} --directory-prefix crypto-config/configtx http://${REMOTE_ORDERER_ADDR}/msp/${ORDERER_NAME}.${DOMAIN}/genesis/${SYSTEM_CHANNEL}_remote.pb
cp crypto-config/configtx/${SYSTEM_CHANNEL}_remote.pb crypto-config/configtx/genesis.pb







