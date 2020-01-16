#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh


export ORG=${ORG:-org1}



TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})
printInColor "1;36" "Creating ${TEST_CHANNEL_NAME} channel in ${ORG}.${DOMAIN} using API..." | printDbg

getAPIPort()
{
port=$(docker inspect api.${1}.${2} | jq '.[0].NetworkSettings.Ports."3000/tcp"[0].HostPort' | tr -d '"')
echo $port
}

getAPIHost()
{
#echo "docker inspect api.${1}.${2} "

ipaddr=$(docker inspect api.${1}.${2} | jq '.[0].NetworkSettings.Ports."3000/tcp"[0].HostIp' | tr -d '"')
addr=$(echo $ipaddr | sed -e 's/0\.0\.0\.0/127.0.0.1/')
echo $addr
}



curlItGet()
{
local url=$1
local cdata=$2
local wtoken=$3

    res=$(curl -sw "%{http_code}"  "${url}" -d "${cdata}" -H "Content-Type: application/json" -H "Authorization: Bearer ${wtoken}")
    http_code="${res:${#res}-3}"
    if [ ${#res} -eq 3 ]; then
      body=""
    else
      body="${res:0:${#res}-3}"
    fi
    jwt=$(echo ${body}) 
    echo "$jwt $http_code"
}

api_ip=$(getAPIHost ${ORG} ${DOMAIN})
api_port=$(getAPIPort ${ORG} ${DOMAIN})


read jwt jwt_http_code < <(curlItGet "http://${api_ip}:${api_port}/users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}"; echo)


jwt=$(echo $jwt | tr -d '"')




if [[ "$jwt_http_code" -eq 200 ]]; then
    printGreen "\nOK: JWT token obtained."
else
    printError "\nERROR: Can not authorize. Failed to get JWT token!\nSee ${FSTEST_LOG_FILE} for logs."
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

if [[ "$create_http_code" -eq 200 ]]; then
    printGreen "\nOK: ${TEST_CHANNEL_NAME}: ${message}"
    exit 0
else
    printError "\nERROR: creating ${TEST_CHANNEL_NAME} channel!\nSee ${FSTEST_LOG_FILE} for logs."
    exit 1
fi
