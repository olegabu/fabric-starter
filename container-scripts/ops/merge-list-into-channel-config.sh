#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_ORG=${2:?New orderer org hosting certificates is requreid}
NEWCONSENTER_DOMAIN=${3}
NEWCONSENTER_PORT=${4:-7050}

echo -e "\n\n\n\n"

set -x
RAFT_NEWCONSENTER_ADDR=${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}:${NEWCONSENTER_PORT} envsubst < './templates/raft/addresses.json' > crypto-config/configtx/addresses_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json

txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}

mergeListIntoChannelConfig ${SYSTEM_CHANNEL_ID} 'crypto-config/configtx/config.json' 'channel_group.values.OrdererAddresses.value.addresses' \
                                                    crypto-config/configtx/addresses_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json 'addresses'
set +x


createConfigUpdateEnvelope ${SYSTEM_CHANNEL_ID}

sleep 5
$BASEDIR/retrieve-latest-config.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_ORG} ${NEWCONSENTER_DOMAIN} ${NEWCONSENTER_PORT}
