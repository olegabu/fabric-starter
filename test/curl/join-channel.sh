#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/../libs.sh

ORG=${2:-${ORG}}
ORG=${ORG:-org1}

export ORG
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${BASEDIR}/fs_network_test.log"}}


TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})
printInColor "1;36" "Joining ${ORG}.${DOMAIN} to the ${TEST_CHANNEL_NAME} channel using API..." | printToLogAndToScreen


api_ip=$(getAPIHost ${ORG} ${DOMAIN})
api_port=$(getAPIPort ${ORG} ${DOMAIN})

read jwt jwt_http_code < <(curlItGet "http://${api_ip}:${api_port}/users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}"; echo)
jwt=$(echo $jwt | tr -d '"')

if [[ "$jwt_http_code" -eq 200 ]]; then
    printGreen "\nOK: JWT token obtained." | printToLogAndToScreen
else
    printError "\nERROR: Can not authorize. Failed to get JWT token!\nSee ${FSTEST_LOG_FILE} for logs." | printToLogAndToScreen
    exit 1
fi

read reply_text reply_code < <(curlItGet  "http://${api_ip}:${api_port}/channels/${TEST_CHANNEL_NAME}" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"waitForTransactionEvent\":false}" "${jwt}";echo)
read reply_text reply_code < <(curlItGet  "http://${api_ip}:${api_port}/channels/${TEST_CHANNEL_NAME}" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"waitForTransactionEvent\":true}" "${jwt}";echo)


if [[ "$reply_code" -eq 200 ]]; then
    printGreen "\nOK: ${ORG} joined to ${TEST_CHANNEL_NAME} channel" | printToLogAndToScreen
    exit 0
else
    printError "\nERROR: joining ${ORG} to ${TEST_CHANNEL_NAME} failed!\nSee ${FSTEST_LOG_FILE} for logs." | printToLogAndToScreen
    exit 1
fi


