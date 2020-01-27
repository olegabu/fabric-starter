#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh


ORG2=${2:-${ORG2}}
ORG=${ORG:-org1}
ORG2=${ORG2:-org1}

export ORG=${ORG:-org1}
export ORG2=${ORG2:-org2}


TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})
printInColor "1;36" "Add ${ORG2} to the ${TEST_CHANNEL_NAME} channel using API..." | printLogScreen


api_ip=$(getAPIHost ${ORG} ${DOMAIN})
api_port=$(getAPIPort ${ORG} ${DOMAIN})


read jwt jwt_http_code < <(curlItGet "http://${api_ip}:${api_port}/users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}"; echo)
jwt=$(echo $jwt | tr -d '"')

if [[ "$jwt_http_code" -eq 200 ]]; then
    printGreen "\nOK: JWT token obtained." | printLogScreen
else
    printError "\nERROR: Can not authorize. Failed to get JWT token!\nSee ${FSTEST_LOG_FILE} for logs." | printLogScreen
    exit 1
fi


sleep 2

read reply_code create_http_code < <(curlItGet  "http://${api_ip}:${api_port}/channels/${TEST_CHANNEL_NAME}/orgs" "{\"orgId\":\"${ORG2}\",\"waitForTransactionEvent\":true}" "${jwt}")

#create_status=$(echo -n ${reply} | jq '.[0].status + .[0].response.status')
#state=$(echo ${create_status} | sed -E -e 's/\n|\r|\s//g')


#if [[ "${state}" -eq 200 ]]; then
#    message="Org added."
#fi
#if [[ "${state}" -eq 500 ]]; then
#    message="Org has been added already."
#fi

if [[ "$reply_code" -eq 200 ]]; then
    printGreen "\nOK: ${ORG2} added to ${TEST_CHANNEL_NAME} channel" | printLogScreen
    exit 0
else
    printError "\nERROR: adding ${ORG2} to ${TEST_CHANNEL_NAME} failed!\nSee ${FSTEST_LOG_FILE} for logs." | printLogScreen
    exit 1
fi




