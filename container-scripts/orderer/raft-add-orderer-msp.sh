#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source $BASEDIR/../lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion


NEWORDERER_MSP_NAME=${1:?New Orderer name is requried}
NEWORDERER_DOMAIN=${2:?New orderer domain is required}
NEWORDERER_WWW_PORT=${3:?New orderer www port is required}

echo -e "\n\nAdd Orderer MSP: ${NEWORDERER_MSP_NAME}, ${NEWORDERER_DOMAIN}\n\n"

downloadOrdererMSP ${NEWORDERER_MSP_NAME} ${NEWORDERER_DOMAIN} ${NEWORDERER_WWW_PORT}

certificationsToEnv orderer ${NEWORDERER_DOMAIN}

insertObjectIntoChannelConfig ${SYSTEM_CHANNEL_ID} ${NEWORDERER_MSP_NAME}.${NEWORDERER_DOMAIN} 'templates/raft/Orderer.json'

difference=`diff crypto-config/configtx/config.json crypto-config/configtx/updated_config.json`

if [ -n "$difference" ]; then
    echo -e "\n Creating config update envelope:\n"
    createConfigUpdateEnvelope ${SYSTEM_CHANNEL_ID}
else
    echo -e "\n No difference in configs. Skipping update config block.\n"
fi

sleep 5
$BASEDIR/../ops/retrieve-latest-config.sh ${NEWORDERER_MSP_NAME} ${NEWORDERER_DOMAIN}

