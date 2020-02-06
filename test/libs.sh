#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

main() {
    export FABRIC_DIR=${FABRIC_DIR:-$(getFabricStarterPath $(pwd))}
    
    pushd ${FABRIC_DIR} > /dev/null && source ./lib/util/util.sh && source ./lib.sh && popd > /dev/null
    
    : ${FSTEST_LOG_FILE:=${FSTEST_LOG_FILE:-"${BASEDIR}/fs_network_test.log"}}
    
    export FSTEST_LOG_FILE=$(realpath ${FSTEST_LOG_FILE})
    
    # Do not be too much verbose
    DEBUG=${DEBUG:-false}
    if [[ "$DEBUG" = "false" ]]; then
        output='/dev/null'
    else
        output='/dev/stdout'
    fi
    export output
    
    SCREEN_OUTPUT_DEVICE=${SCREEN_OUTPUT_DEVICE:-/dev/tty}
    
}

function getFabricStarterPath() {
    dirname=${1}
    libpath=$(realpath "${dirname}"/lib.sh)
    
    if [[ ! -f ${libpath} ]]; then
        dirname=$(realpath "${dirname}"/../)
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

function printLogScreenCyan() {
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        printInColor "1;36" "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}

function printNoColors() {   #filter out set color terminal commands
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
        done
    else
        echo  "$@" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
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

function printErrLogScreen() {
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE} >/dev/stderr
        done
    else
        echo "$@" | tee -a ${FSTEST_LOG_FILE} > /dev/stderr
    fi
}


function printAndCompareResults() {
    
    messageOK=${1}
    messageERR=${2}
    var=${3:-"$?"}
    value=${4:-0}
    
    if [ "$var" = "$value" ]; then
        printGreen "${messageOK}"
        exit 0
    else
        printError "${messageERR}"
        exit 1
    fi
}

function printResultAndSetExitCode() {
    if [ $? -eq 0 ]
    then
        printGreen "OK: $@" | printLogScreen
        exit 0
    else
        printError "ERROR! See ${FSTEST_LOG_FILE} for logs." | printErrLogScreen
        exit 1
    fi
}

function queryContainerNetworkSettings() {
    local parameter="${1}" # [HostPort|HostIp]
    local container="${2}"
    local organization="${3}"
    local domain="${4}"
    
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local query='.[0].NetworkSettings.Ports | keys[] as $k | "\(.[$k]|.[0].'"${parameter}"')"'
    local result=$(docker inspect ${container}.${organization}.${domain} | jq -r "${query}" 2>${TMP_LOG_FILE});
    echo  "queryContainerNetworkSettings returns:" ${result} | printLog
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    echo $result
}

# function getAPIPort() {
#     local container="${1}" organization="${2}" domain="${3}"
#     queryContainerNetworkSettings "HostPort" ${container} ${organization} ${domain}
# }

# function getAPIHost() {
#     local container="${1}" organization="${2}" domain="${3}"
#     queryContainerNetworkSettings "HostIp" ${container} ${organization} ${domain}
# }

# function getPeer0Port() {
#     local container="${1}" organization="${2}" domain="${3}"
#     queryContainerNetworkSettings "HostPort" ${container} ${organization} ${domain}
# }


# function getPeer0Host() {
#     local container="${1}" organization="${2}" domain="${3}"
#     queryContainerNetworkSettings "HostIp" ${container} ${organization} ${domain}
# }

function getContainerPort () {
    local org="${1:?Org name is required}"
    local container_name="${2:?Container name is required}"
    local domain="${3:-${DOMAIN:?Domain is required}}"
    echo $(queryContainerNetworkSettings "HostPort" "${container_name}" "${org}" "${domain}")
}

function curlItGet()
{
    local url=$1
    local cdata=$2
    local wtoken=$3
    res=$(curl -sw "%{http_code}" "${url}" -d "${cdata}" -H "Content-Type: application/json" -H "Authorization: Bearer ${wtoken}")
    #    echo " +++++++ $res +++++++"  >/dev/tty
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

function restquery {
    local org=${1}
    local path=${2}
    local query=${3}
    local jwt=${4}
    
    local ip_var_name="API_${org}_HOST"
    local port_var_name="API_${org}_PORT"
    
    local api_ip=${!ip_var_name}
    local api_port=${!port_var_name}
    
    curlItGet "http://${api_ip}:${api_port}/${path}" "${query}" "${jwt}"
}


function getJWT() {
    local org=${1}
    #    local api_ip=$(getAPIHost api ${org} ${DOMAIN})
    #    local api_port=$(getAPIPort api ${org} ${DOMAIN})
    
    restquery ${org} "users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}" ""
}

function APIAuthorize() {
    result=($(getJWT ${1}))
    
    local jwt=${result[0]//\"/} #remove quotation marks
    local jwt_http_code=${result[1]}
    echo "Got JWT: ${jwt}" | printLog
    echo "${jwt}"
    
    [ "${jwt_http_code}" = "200" ]
    printResultAndSetExitCode "JWT token obtained." > ${SCREEN_OUTPUT_DEVICE}
}

function DeleteSpacesLineBreaks() {
    echo ${1} | sed -E -e 's/\n|\r|\s//g'
}

function createChannelAPI_()
{
    local channel=${1}
    local org=${2}
    local jwt=${3}
    
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local result=$(restquery ${2} "channels" "{\"channelId\":\"${channel}\",\"waitForTransactionEvent\":true}" "${jwt}")  2>${TMP_LOG_FILE}
    printDbg $result > ${SCREEN_OUTPUT_DEVICE}
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    echo ${result}
}


function createChannelAPI() {
    local channel=${1}
    local org=${2}
    local jwt=${3}
    
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local result=($(createChannelAPI_ "${channel}" "${org}" "${jwt}"))
    local create_status=$(echo -n ${result[0]} | jq '.[0].status + .[0].response.status' 2>${TMP_LOG_FILE})
    
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    
    local state=$(DeleteSpacesLineBreaks "${create_status}")
    local create_http_code=${result[1]}
    
    #setExitCode
    [ "${create_http_code}" = "200" ]
}

function addOrgToChannel_(){
    local result=$(restquery ${2} "channels/${TEST_CHANNEL_NAME}/orgs" "{\"orgId\":\"${org2}\",\"waitForTransactionEvent\":true}" "${jwt}")  2>${TMP_LOG_FILE}
    printDbg $result > ${SCREEN_OUTPUT_DEVICE}
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    #echo ${result}> ${SCREEN_OUTPUT_DEVICE}
    echo ${result}
}

function addOrgToChannel() {
    local channel=${1}
    local org=${2}
    local jwt=${3}
    local org2=${4}
    
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local result=($(addOrgToChannel_ "${channel}" "${org}" "${jwt}" "${org2}"))
    #is just a 200 code
    local create_status=$(echo -n ${result[0]} | jq '.[0].status + .[0].response.status' 2>${TMP_LOG_FILE})
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    
    local state=$(DeleteSpacesLineBreaks "${create_status}")
    local create_http_code=${result[1]}
    
    [ "${create_http_code}" = "200" ]
}

function queryPeer() {
    local channel=${1}
    local org=${2}
    local query=${3}
    local subquery=${4:-.}
    
    
    TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    
    local result=$(docker exec cli.${org}.${DOMAIN} /bin/bash -c \
        'source container-scripts/lib/container-lib.sh; \
        peer channel fetch config /dev/stdout -o $ORDERER_ADDRESS -c '${channel}' $ORDERER_TLSCA_CERT_OPTS | \
        configtxlator  proto_decode --type "common.Block"  | \
    jq '${query}' | tee /dev/stderr | jq -r '${subquery}' ' 2>"${TMP_LOG_FILE}")
    cat "${TMP_LOG_FILE}" | printDbg > ${SCREEN_OUTPUT_DEVICE}
    echo $result
}

function verifyChannelExists() {
    local channel=${1}
    local org=${2}
    
    local result=$(queryPeer ${channel} ${org} '.data.data[0].payload.header.channel_header' '.channel_id')
    
    [ "${result}" = "${channel}" ]
}

function runInFabricDir() {
    pushd ${FABRIC_DIR} >/dev/null
    
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local exit_code
    
    eval "$@" > "${TMP_LOG_FILE}"; exit_code=$?
    
    cat "${TMP_LOG_FILE}" | printDbg
    popd >/dev/null
    
    [ "${exit_code}" = "0" ]
}


main $@