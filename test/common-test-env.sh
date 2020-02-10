#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

export DOMAIN=${1:-${DOMAIN:-example.com}}

export TEST_CHANNEL_NAME=${TEST_CHANNEL_NAME:-$(getRandomChannelName)}

source ${BASEDIR}/parse-common-params.sh $TEST_CHANNEL_NAME $2 $3

ORG1_HOST=$(getOrgIp "${ORG1}")
ORG2_HOST=$(getOrgIp "${ORG2}")


export API1_HOST=${ORG1_HOST}
export API2_HOST=${ORG2_HOST}

export PEER1_HOST=${ORG1_HOST}
export PEER2_HOST=${ORG2_HOST}

export API_"${ORG1}"_HOST=${API1_HOST}
export API_"${ORG2}"_HOST=${API2_HOST}
export PEER0_"${ORG1}"_HOST=${PEER1_HOST}
export PEER0_"${ORG2}"_HOST=${PEER2_HOST}

export API1_PORT=$(getOrgContainerPort  "${ORG1}" "${API_NAME}" "${DOMAIN}")
export PEER1_PORT=$(getOrgContainerPort "${ORG1}" "${PEER_NAME}" "${DOMAIN}")
export API2_PORT=$(getOrgContainerPort "${ORG2}" "${API_NAME}" "${DOMAIN}")
export PEER2_PORT=$(getOrgContainerPort "${ORG2}" "${PEER_NAME}" "${DOMAIN}")


export API_"${ORG1}"_PORT=${API1_PORT}
export API_"${ORG2}"_PORT=${API2_PORT}
export PEER0_"${ORG1}"_PORT=${PEER1_PORT}
export PEER0_"${ORG2}"_PORT=${PEER2_PORT}

#____________________________________________________

echo "API ${ORG1}: ${API1_HOST}:${API1_PORT}"
echo "API ${ORG2}: ${API2_HOST}:${API2_PORT}"

echo "PEER ${ORG1}: ${PEER1_HOST}:${PEER1_PORT}"
echo "PEER ${ORG2}: ${PEER2_HOST}:${PEER2_PORT}"

echo ${FSTEST_LOG_FILE}
echo ${FABRIC_DIR}
echo ${TEST_CHANNEL_NAME}