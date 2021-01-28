#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_DOMAIN=${2:?New Conseneter domain is requried}
NEWCONSENTER_PORT=${3:-7050}


RAFT_NEWCONSENTER_ADDR=${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}:${NEWCONSENTER_PORT} envsubst < './templates/raft/addresses.json' > crypto-config/configtx/addresses_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json

#txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}

$BASEDIR/../ops/merge-list-into-channel-config.sh  ${SYSTEM_CHANNEL_ID} 'crypto-config/configtx/config.json' 'channel_group.values.OrdererAddresses.value.addresses' \
                                                    crypto-config/configtx/addresses_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json 'addresses'

sleep 5
$BASEDIR/../ops/retrieve-latest-config.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN}
