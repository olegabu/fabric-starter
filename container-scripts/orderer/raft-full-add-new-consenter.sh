#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_DOMAIN=${2}
NEWCONSENTER_PORT=${3:-7050}
NEWCONSENTER_WWW_PORT=${4:-80}
CHANNEL=${5:-${SYSTEM_CHANNEL_ID}}


NAME_DOMAIN=${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}

echo -e "\n\nAdd Consenter's MSP: ${NEWCONSENTER_NAME}, ${NEWCONSENTER_DOMAIN}\n\n"
downloadOrdererMSP ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN} ${NEWCONSENTER_WWW_PORT}
certificationsToEnv orderer ${NEWCONSENTER_DOMAIN}
insertObjectIntoChannelConfig ${CHANNEL} ${NAME_DOMAIN} 'templates/raft/Orderer.json' 'xxxx' 'crypto-config/configtx/updated_config_msp.json'


echo -e "\n\nAdd Concenter: ${NEWCONSENTER_NAME}, ${NEWCONSENTER_DOMAIN}\n\n"
export "RAFT_NEWCONSENTER_HOST"=${NAME_DOMAIN}
export "RAFT_NEWCONSENTER_PORT"=${NEWCONSENTER_PORT}
export "RAFT_NEWCONSENTER_CLIENT_TLS_CERT"=`cat crypto-config/ordererOrganizations/${NEWCONSENTER_DOMAIN}/msp/${RAFT_NEWCONSENTER_HOST}/tls/server.crt | base64 | tr -d '\n'`
export "RAFT_NEWCONSENTER_SERVER_TLS_CERT"=`cat crypto-config/ordererOrganizations/${NEWCONSENTER_DOMAIN}/msp/${RAFT_NEWCONSENTER_HOST}/tls/server.crt | base64 | tr -d '\n'`
envsubst < './templates/raft/consenters.json' > crypto-config/configtx/consenters_${RAFT_NEWCONSENTER_HOST}.json
mergeListIntoChannelConfig ${CHANNEL} 'crypto-config/configtx/updated_config_msp.json' 'channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters' \
                            crypto-config/configtx/consenters_${RAFT_NEWCONSENTER_HOST}.json 'consenters' 'crypto-config/configtx/updated_config_concenter.json'


echo -e "\n\nAdd Endpoint: ${NEWCONSENTER_NAME}, ${NEWCONSENTER_DOMAIN}\n\n"
RAFT_NEWCONSENTER_ADDR=${NAME_DOMAIN}:${NEWCONSENTER_PORT} envsubst < './templates/raft/addresses.json' > crypto-config/configtx/addresses_${NAME_DOMAIN}.json
mergeListIntoChannelConfig ${CHANNEL} 'crypto-config/configtx/updated_config_concenter.json' 'channel_group.values.OrdererAddresses.value.addresses' \
                            crypto-config/configtx/addresses_${NAME_DOMAIN}.json 'addresses' 'crypto-config/configtx/updated_config.json'


echo -e "\n Creating config update envelope:\n"
createConfigUpdateEnvelope ${CHANNEL}

sleep 8
$BASEDIR/../ops/retrieve-latest-config.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN}



