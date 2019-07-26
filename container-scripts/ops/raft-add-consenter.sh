#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_DOMAIN=${2}
NEWCONSENTER_PORT=${3:-7050}


export RAFT_NEWCONSENTER_CLIENT_TLS_CERT=`cat crypto-config/ordererOrganizations/${NEWCONSENTER_DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/tls/server.crt | base64 -w 0`
export RAFT_NEWCONSENTER_SERVER_TLS_CERT=`cat crypto-config/ordererOrganizations/${NEWCONSENTER_DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/tls/server.crt | base64 -w 0`

export RAFT_NEWCONSENTER_HOST=${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}
export RAFT_NEWCONSENTER_PORT=${NEWCONSENTER_PORT}

envsubst < './templates/raft/consenters.json' > crypto-config/configtx/consenters_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json

#txTranslateChannelConfigBlock ${SYSTEM_CHANNEL_ID}

#mergeListIntoChannelConfig ${SYSTEM_CHANNEL_ID} 'crypto-config/configtx/config.json' 'channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters' \
#                                                    crypto-config/configtx/consenters_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json 'consenters'
#
#createConfigUpdateEnvelope ${SYSTEM_CHANNEL_ID}

#$BASEDIR/merge-list-into-channel-config.sh  ${SYSTEM_CHANNEL_ID} 'crypto-config/configtx/config.json' 'channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters' \
#                                                    crypto-config/configtx/consenters_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json 'consenters'


sleep 5
set -x
$BASEDIR/retrieve-latest-config.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN}
set +x
