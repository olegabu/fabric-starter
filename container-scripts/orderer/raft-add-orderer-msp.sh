#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

BASEDIR=$(dirname "$0")

NEWORDERER_MSP_NAME=${1:?New Orderer name is requried}
NEWORDERER_DOMAIN=${2:-New orderer domain is required}
NEWORDERER_WWW_PORT=${3:-New orderer port is required}

echo -e "\n\nAdd new consenter: ${NEWORDERER_MSP_NAME}, ${NEWORDERER_DOMAIN}\n\n"

downloadOrdererMSP ${NEWORDERER_MSP_NAME} ${NEWORDERER_DOMAIN} ${NEWORDERER_WWW_PORT}

certificationsToEnv orderer ${NEWORDERER_DOMAIN}

insertObjectIntoChannelConfig ${SYSTEM_CHANNEL_ID} orderer.${NEWORDERER_DOMAIN} 'templates/raft/Orderer.json'

createConfigUpdateEnvelope ${SYSTEM_CHANNEL_ID}

sleep 5
$BASEDIR/retrieve-latest-config.sh ${NEWORDERER_MSP_NAME} ${NEWORDERER_DOMAIN}

