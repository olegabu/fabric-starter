#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

export DOMAIN=${1:-${DOMAIN:-example.com}}

source ${BASEDIR}/parse-common-params.sh $TEST_CHANNEL_NAME $2 $3


echo "API ${ORG1}: $(getOrgIp $2):$(getOrgContainerPort  "$2" "${API_NAME}" "${DOMAIN}")"
echo "API ${ORG2}: $(getOrgIp $3):$(getOrgContainerPort  "$3" "${API_NAME}" "${DOMAIN}")"

echo ${FSTEST_LOG_FILE}
echo ${FABRIC_DIR}