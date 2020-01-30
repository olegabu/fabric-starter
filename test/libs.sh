#!/usr/bin/env bash


BASEDIR=$(dirname $0)
CURRENT_DIR=$(pwd)
FULL_PATH=${CURRENT_DIR}

: ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-${BASEDIR}/fs_network_test.log}}
export FSTEST_LOG_FILE

# Do not be too much verbose
DEBUG=${DEBUG:-true}
if [[ "$DEBUG" = "false" ]]; then
    output='/dev/null'
else
    output='/dev/stdout'
fi
export output


function getFabricStarterPath() {
    dirname=${1}
    libpath=$(realpath ${dirname}/lib.sh)
    
    if [[ ! -f ${libpath} ]]; then
        dirname=$(realpath ${dirname}/../)
        getFabricStarterPath ${dirname}
    else
        
        if [[ $dirname != '/' ]]; then
            echo ${dirname}
        else
            echo "Run tests in fabric-starter directory!"
            exit 1
        fi
    fi
}

function printDbg() {
    
    if [[ "$DEBUG" = "false" ]]; then
        outputdev=/dev/null
    else
        outputdev=/dev/stdout
    fi
    
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE} > ${outputdev}
        done
        #	echo $(cat < /dev/stdin) | tee -a ${FSTEST_LOG_FILE} > ${outputdev}
    else
        echo "$@" | tee -a ${FSTEST_LOG_FILE} > ${outputdev}
    fi
}

function printLog() {
    
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | cat >> ${FSTEST_LOG_FILE}
        done
    else
        echo "$@" | cat >> ${FSTEST_LOG_FILE}
    fi
}

function printLogScreen() {
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        echo "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}

function printAndCompareResults() {
    
    messageOK=${1}
    messageERR=${2}
    var=${3:-?}
    value=${4:-0}
    
    if [[ "$var" -eq "$value" ]]; then
        printGreen "${messageOK}"
        exit 0
    else
        printError "${messageERR}"
        exit 1
    fi
}


function querryAPI() {
    local parameter="${1}" # [HostPort|HostIp]
    local container="${2}"
    local organization="${3}"
    local domain="${4}"
    
    local querry='.[0].NetworkSettings.Ports | keys[] as $k | "\(.[$k]|.[0].'"${parameter}"')"'
    echo $(docker inspect ${container}.${organization}.${domain} | jq -r "${querry}")
    
}

function getAPIPort() {
    local container="${1}" organization="${2}" domain="${3}"
    querryAPI "HostPort" ${container} ${organization} ${domain}
}

function getAPIHost() {
    local container="${1}" organization="${2}" domain="${3}"
    querryAPI "HostIp" ${container} ${organization} ${domain}
}

function getPeer0Port() {
    local container="${1}" organization="${2}" domain="${3}"
    querryAPI "HostPort" ${container} ${organization} ${domain}
}


function getPeer0Host() {
    local container="${1}" organization="${2}" domain="${3}"
    querryAPI "HostIp" ${container} ${organization} ${domain}
}

function curlItGet()
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
    local res=$(echo ${body})
    echo "$res $http_code"
}

function generateMultipartBoudary() {
    echo -n -e "--FabricStarterTestBoundary"$(date | md5sum | head -c 10)
}

function generateMultipartHeader() { #expecting boundary and filename as args
    multipart_header='----'${1}'\r\nContent-Disposition: form-data; name="file"; filename="'
    multipart_header+=${2}'"\r\nContent-Type: "application/zip"\r\n\r\n'
    echo -n -e  ${multipart_header}
}

function generateMultipartTail() { #expecting boundaty as an arg
    boundary=${1}
    
    multipart_tail='\r\n\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n----'
    multipart_tail+=${boundary}'--\r\n'
    echo -n -e ${multipart_tail}
}

function restQuerry {
    local org=${1}
    local path=${2}
    local querry=${3}
    local jwt=${4}
    
    local api_ip=$(getAPIHost api ${org} ${DOMAIN})
    local api_port=$(getAPIPort api ${org} ${DOMAIN})
    
    curlItGet "http://${api_ip}:${api_port}/${path}" "${querry}" "${jwt}"
}


function getJWT() {
    local org=${1}
    local api_ip=$(getAPIHost api ${org} ${DOMAIN})
    local api_port=$(getAPIPort api ${org} ${DOMAIN})
    
    restQuerry ${org} "users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}" ""
}



function APIAuthorize() {
    result=($(getJWT ${1}))
    
    local jwt=${result[0]//\"/} #remove quotation marks
    local jwt_http_code=${result[1]}
    echo "${jwt}"
    printAndCompareResults "\nOK: JWT token obtained." "\nERROR: Can not authorize. Failed to get JWT token!\nSee ${FSTEST_LOG_FILE} for logs." \
    "${jwt_http_code}" "200" > /dev/tty
}

function DeleteSpacesLineBreaks() {
    echo ${1} | sed -E -e 's/\n|\r|\s//g'
}

function createChannelAPI() {
    local channel=${1}
    local org=${2}
    local jwt=${3}

    result=($(restQuerry ${2} "channels" "{\"channelId\":\"${channel}\",\"waitForTransactionEvent\":true}" "${jwt}"))
   
    create_status=$(echo -n ${result[0]} | jq '.[0].status + .[0].response.status')
    state=$(DeleteSpacesLineBreaks "${create_status}")
    create_http_code=${result[1]}
   
    if [[ "${state}" -eq 200 ]]; then
        message="Channel created."
    fi
    if [[ "${state}" -eq 500 ]]; then
        message="Channel already exists."
    fi
    
    printAndCompareResults "\nOK: ${channel}: ${message}" "\nERROR: creating ${channel} channel!\nSee ${FSTEST_LOG_FILE} for logs." \
    ${create_http_code} 200 | printLogScreen > /dev/tty
}


CURRENT_DIR=$(pwd)
cd ${FABRIC_DIR} && source ./lib/util/util.sh && source ./lib.sh
cd ${CURRENT_DIR}