#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWCONSENTER_NAME=${1:?New Orderer name is requried}
NEWCONSENTER_DOMAIN=${2?New Orderer Domain is requried}
NEWCONSENTER_PORT=${3:-7050}
NEWCONSENTER_WWW_PORT=${4:-80}
CHANNEL=${5:-${SYSTEM_CHANNEL_ID}}


downloadOrdererMSP ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN} ${NEWCONSENTER_WWW_PORT}

export RAFT_NEWCONSENTER_CLIENT_TLS_CERT=`eval "cat crypto-config/ordererOrganizations/${NEWCONSENTER_DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/tls/server.crt | base64 ${BASE64_UNWRAP_CODE}"`
export RAFT_NEWCONSENTER_SERVER_TLS_CERT=`eval "cat crypto-config/ordererOrganizations/${NEWCONSENTER_DOMAIN}/msp/${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}/tls/server.crt | base64 ${BASE64_UNWRAP_CODE}"`

export RAFT_NEWCONSENTER_HOST=${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}
export RAFT_NEWCONSENTER_PORT=${NEWCONSENTER_PORT}

envsubst < './templates/raft/consenters.json' > crypto-config/configtx/consenters_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json


$BASEDIR/../ops/merge-list-into-channel-config.sh  ${CHANNEL} 'crypto-config/configtx/config.json' 'channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters' \
                                                    crypto-config/configtx/consenters_${NEWCONSENTER_NAME}.${NEWCONSENTER_DOMAIN}.json 'consenters'

sleep 10
set -x
$BASEDIR/../ops/retrieve-latest-config.sh ${NEWCONSENTER_NAME} ${NEWCONSENTER_DOMAIN}
set +x
