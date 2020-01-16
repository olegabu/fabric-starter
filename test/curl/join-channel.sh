#!/usr/bin/env bash

BASEDIR=$(dirname $0)
source ${BASEDIR}/../libs.sh


#export ORG=${ORG:-org1}
#export ORG2=${ORG2:-org2}

ORG=${2:-${ORG}}
ORG=${ORG:-org1}




TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME}} #($1, if set, or ${TEST_CHANNEL_NAME})
printInColor "1;36" "Joining ${ORG}.${DOMAIN} to the ${TEST_CHANNEL_NAME} channel using API..." | printDbg

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


#curl -m 180 "${url}" -d "${cdata}" -H "Content-Type: application/json" -H "Authorization: Bearer ${wtoken}" 2>&1 >> curl.res
    res=$(curl -sw "%{http_code}"  "${url}" -d "${cdata}" -H "Connection: keep-alive" -H "Content-Type: application/json" -H "Authorization: Bearer ${wtoken}")
#    echo ............. $res >/dev/stdout
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

#echo curlItGet  "http://${api_ip}:${api_port}/channels/${TEST_CHANNEL_NAME}/" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"waitForTransactionEvent\":true}" "${jwt}"
read reply_text reply_code < <(curlItGet  "http://${api_ip}:${api_port}/channels/${TEST_CHANNEL_NAME}" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"waitForTransactionEvent\":true}" "${jwt}";echo) 
#read reply_text reply_code < <(curlItGet  "http://${api_ip}:${api_port}/channels" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"waitForTransactionEvent\":true}" "${jwt}";echo) 

#curlItGet  "http://${api_ip}:${api_port}/channels/${TEST_CHANNEL_NAME}/" "{\"channelId\":\"${TEST_CHANNEL_NAME}\",\"waitForTransactionEvent\":true}" "${jwt}"


if [[ "$reply_code" -eq 200 ]]; then
    printGreen "\nOK: ${ORG} joined to ${TEST_CHANNEL_NAME} channel"
    exit 0
else
    printError "\nERROR: joining ${ORG} to ${TEST_CHANNEL_NAME} failed!\nSee ${FSTEST_LOG_FILE} for logs."
    exit 1
fi


