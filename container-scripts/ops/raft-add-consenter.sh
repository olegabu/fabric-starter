#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_ORG=${2:?New orderer org hosting certificates is requreid}
NEWCONSENTER_DOMAIN=${3}
NEWCONSENTER_PORT=${4:-7050}

echo -e "\n\n${NEWCONSENTER_NAME}, ${NEWCONSENTER_DOMAIN}\n\n"

downloadOrdererMSP ${NEWCONSENTER_NAME} ${NEWCONSENTER_ORG} ${NEWCONSENTER_DOMAIN}

certificationsToEnv orderer ${NEWCONSENTER_DOMAIN}

insertObjectIntoChannelConfig ${SYSTEM_CHANNEL_ID} orderer.${NEWCONSENTER_DOMAIN} 'templates/raft/Orderer.json'


export RAFT_NEWCONSENTER_CLIENT_TLS_CERT=`cat crypto-config/ordererOrganizations/${NEWCONSENTER_DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/tls/server.crt | base64 -w 0`
export RAFT_NEWCONSENTER_SERVER_TLS_CERT=`cat crypto-config/ordererOrganizations/${NEWCONSENTER_DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/tls/server.crt | base64 -w 0`

export RAFT_NEWCONSENTER_HOST=${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}
export RAFT_NEWCONSENTER_PORT=${NEWCONSENTER_PORT}

envsubst < './templates/raft/consenters.json' > crypto-config/configtx/consenters_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json

mergeListIntoChannelConfig ${SYSTEM_CHANNEL_ID} 'crypto-config/configtx/updated_config.json' 'channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters' \
                                                    crypto-config/configtx/consenters_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json 'consenters'

createConfigUpdateEnvelope ${SYSTEM_CHANNEL_ID}

sleep 5
$BASEDIR/retrieve-latest-config.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_ORG} ${NEWCONSENTER_DOMAIN} ${NEWCONSENTER_PORT}

