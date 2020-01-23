#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh
: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}
export ORG=${ORG:-org1}
TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})

printInColor "1;36" "Creating ${TEST_CHANNEL_NAME} channel in ${ORG}.${DOMAIN} using API..." | printDbg


api_ip=$(getAPIHost ${ORG} ${DOMAIN})
api_port=$(getAPIPort ${ORG} ${DOMAIN})


read jwt jwt_http_code < <(curlItGet "http://${api_ip}:${api_port}/users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}"; echo)


jwt=$(echo $jwt | tr -d '"')
printDbg "JWT obtained: $jwt"



if [[ "$jwt_http_code" -eq 200 ]]; then
    printGreen "\nOK: JWT token obtained." | printDbg

else
    printError "\nERROR: Can not authorize. Failed to get JWT token!\nSee ${FSTEST_LOG_FILE} for logs." | printDbg

    exit 1
fi


sleep 2

read reply create_http_code < <(curlItGet  "http://${api_ip}:${api_port}/channels/" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"waitForTransactionEvent\":true}" "${jwt}")

create_status=$(echo -n ${reply} | jq '.[0].status + .[0].response.status')
state=$(echo ${create_status} | sed -E -e 's/\n|\r|\s//g')


if [[ "${state}" -eq 200 ]]; then
    message="Channel created."
fi
if [[ "${state}" -eq 500 ]]; then
    message="Channel already exists."
fi

printDbg $message

if [[ "$create_http_code" -eq 200 ]]; then
    printGreen "\nOK: ${TEST_CHANNEL_NAME}: ${message}" | printDbg

    exit 0
else
    printError "\nERROR: creating ${TEST_CHANNEL_NAME} channel!\nSee ${FSTEST_LOG_FILE} for logs." | printDbg

    exit 1
fi
