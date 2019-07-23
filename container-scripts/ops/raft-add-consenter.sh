#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null

NEWORDERER_NAME=${1:?New Orderer name is requried}
NEWORDERER_DOMAIN=${2:-${DOMAIN}}
echo -e "\n\n${NEWORDERER_NAME}, ${NEWORDERER_DOMAIN}\n\n"
downloadOrdererMSP ${NEWORDERER_NAME} ${NEWORDERER_DOMAIN}

certificationsToEnv orderer ${NEWORDERER_DOMAIN}

insertObjectIntoChannelConfig ${SYSTEM_CHANNEL_ID} orderer.${NEWORDERER_DOMAIN} 'templates/raft/Orderer.json'

RAFT_NEWORDERER_ADDR=${NEWORDERER_NAME}.${NEWORDERER_DOMAIN}:${NEWORDERER_PORT:-7050} envsubst < './templates/raft/addresses.json' > crypto-config/configtx/addresses_${NEWORDERER_NAME}.json

mergeListIntoChannelConfig ${SYSTEM_CHANNEL_ID} 'crypto-config/configtx/updated_config.json' 'channel_group.values.OrdererAddresses.value.addresses' \
                                                    crypto-config/configtx/addresses_${NEWORDERER_NAME}.json 'addresses'

export RAFT_NEWORDERER_CLIENT_TLS_CERT=`cat crypto-config/ordererOrganizations/${NEWORDERER_DOMAIN}/msp/${NEWORDERER_NAME}.${NEWORDERER_DOMAIN}/tls/server.crt | base64 -w 0`
export RAFT_NEWORDERER_SERVER_TLS_CERT=`cat crypto-config/ordererOrganizations/${NEWORDERER_DOMAIN}/msp/${NEWORDERER_NAME}.${NEWORDERER_DOMAIN}/tls/server.crt | base64 -w 0`

export RAFT_NEWORDERER_HOST=${NEWORDERER_NAME}.${NEWORDERER_DOMAIN}
export RAFT_NEWORDERER_PORT=${NEWORDERER_PORT:-7050}

envsubst < './templates/raft/consenters.json' > crypto-config/configtx/consenters_${NEWORDERER_NAME}.json

mergeListIntoChannelConfig ${SYSTEM_CHANNEL_ID} 'crypto-config/configtx/updated_config.json' 'channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters' \
#                                                    crypto-config/configtx/consenters_${NEWORDERER_NAME}.json 'consenters'

createConfigUpdateEnvelope ${SYSTEM_CHANNEL_ID}

sleep 4
txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}

updatedConfigBlockDir=crypto-config/ordererOrganizations/${DOMAIN}/msp/${NEWORDERER_NAME}.${NEWORDERER_DOMAIN}/genesis
echo "Copy updated genesis block to ${updatedConfigBlockDir}"
mkdir -p ${updatedConfigBlockDir}
cp crypto-config/configtx/${SYSTEM_CHANNEL_ID}.pb ${updatedConfigBlockDir}/${SYSTEM_CHANNEL_ID}_remote.pb

