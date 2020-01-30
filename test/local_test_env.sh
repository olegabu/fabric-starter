#!/usr/bin/env bash

#Assuming local Fabric installation

BASEDIR=$(dirname $0)
source ./libs.sh


START_DIR=$(pwd)


export DOMAIN=${1:-${$DOMAIN:-example.com}}
export ORG=${ORG1:-${2:-org1}}
export ORG1=${ORG}
export ORG2=${ORG2:-${3:-org2}}


PEER_NAME=${PEER_NAME:-peer0}
API_NAME=${API_NAME:-api}


export API1_PORT=$(getAPIPort "${API_NAME}" "${ORG1}" "${DOMAIN}")
export API2_PORT=$(getAPIPort "${API_NAME}" "${ORG2}" "${DOMAIN}")

export API1_HOST=$(getAPIHost "${API_NAME}" "${ORG1}" "${DOMAIN}")
export API2_HOST=$(getAPIHost "${API_NAME}" "${ORG2}" "${DOMAIN}")

export PEER1_PORT=$(getPeer0Port "${PEER_NAME}" "${ORG1}" "${DOMAIN}")
export PEER2_PORT=$(getPeer0Port "${PEER_NAME}" "${ORG2}" "${DOMAIN}")

export PEER1_HOST=$(getPeer0Host "${PEER_NAME}" "${ORG1}" "${DOMAIN}")
export PEER2_HOST=$(getPeer0Host "${PEER_NAME}" "${ORG2}" "${DOMAIN}")

export TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME:-'testlocal'$RANDOM}

echo "API org1: ${API1_HOST}:${API1_PORT}"
echo "API org2: ${API2_HOST}:${API2_PORT}"

echo "PEER org1: ${PEER1_HOST}:${PEER1_PORT}"
echo "PEER org2: ${PEER2_HOST}:${PEER2_PORT}"

echo ${FSTEST_LOG_FILE}
echo ${FABRIC_DIR}
echo ${TEST_CHANNEL_NAME}