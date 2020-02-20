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
    exportColors
    SCREEN_OUTPUT_DEVICE=${SCREEN_OUTPUT_DEVICE:-/dev/stderr}
}


function arrayStartIndex() { #bash starts with 0, zhs starts with 1
    local array=(1 0)
    echo ${array[1]}
}

function DeleteSpacesLineBreaks() {
    echo "${1}"| sed -E -e 's/\n|\r|\s//g'
}

function getRandomChannelName() {
    echo testchannel"${RANDOM}"
}

function setExitCode() {
    eval "${@}"
}

function exportColors() {
    export  BLACK=$(tput setaf 0)
    export  RED=$(tput setaf 1)
    export  GREEN=$(tput setaf 2)
    export  YELLOW=$(tput setaf 3)
    export  LIME_YELLOW=$(tput setaf 190)
    export  POWDER_BLUE=$(tput setaf 153)
    export  BLUE=$(tput setaf 4)
    export  MAGENTA=$(tput setaf 5)
    export  CYAN=$(tput setaf 6)
    export  WHITE=$(tput setaf 7)
    export  BRIGHT=$(tput bold)
    export  NORMAL=$(tput sgr0)
    export  BLINK=$(tput blink)
    export  REVERSE=$(tput smso)
    export  UNDERLINE=$(tput smul)
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


function getFabricStarterPath() {
    local dirname=${1}
    local libpath=$(realpath "${dirname}"/lib.sh)
    
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
        local outputdev=/dev/null
    else
        local outputdev=/dev/stdout
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

function printToLogAndToScreenCyan() {
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        printInColor "1;36" "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}


function printToLogAndToScreenBlue() {
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        printInColor "1;34" "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}



function printNSymbols() {
    local string=$1
    local num=$2
    local res=$(printf "%-${num}s" "$string")
    echo "${res// /"${string}"}"

}

function printNSpaces() {
    local count=0 ;
    local output=""

    while [[ $count -lt $1 ]];
    do output+='_';
        let count++;
    done
    echo ${output//_/ }
}

function printPaddingSpaces() {
    local string=$1
    local string2=$2
    local shifter=$3
    local plain_string=$(printNoColors $string)
    local full_length=${#string}
    local symbol_length=${#plain_string}
    local spaces=$(( full_length - symbol_length - shifter))

    echo "$(printNSpaces ${spaces})""${string2}"
}


function printYellowBox() {
    
    local length=$(expr length "$@")
    local indent=10
    local boundary=$(printNSymbols '=' $((length + $indent * 2)) )
    local indentation=$(printNSymbols ' ' $indent )
    
    printYellow "\n${boundary}\n${indentation}$@\n${boundary}\n"
}


function printExitCode() {
    if [ "$1" = "0" ]; then printGreen "Exit code: $1"; else printError "Exit code: $1"; fi
}


function printToLogAndToScreen() {
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        echo "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}


function printErrToLogAndToScreen() {
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE} >/dev/stderr
        done
    else
        echo "$@" | tee -a ${FSTEST_LOG_FILE} > /dev/stderr
    fi
}


function printAndCompareResults() {
    
    local messageOK=${1}
    local messageERR=${2}
    local var=${3:-"$?"}
    local value=${4:-0}
    
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
        printGreen "OK: $@" | printToLogAndToScreen
        exit 0
    else
        if [ "${NO_RED_OUTPUT}" = true ]; then
            printWhite "See ${FSTEST_LOG_FILE} for logs." | printErrToLogAndToScreen
        else
            printError "ERROR! See ${FSTEST_LOG_FILE} for logs." | printErrToLogAndToScreen
        fi
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


function getContainerPort () {
    local org="${1:?Org name is required}"
    local container_name="${2:?Container name is required}"
    local domain="${3:-${DOMAIN:?Domain is required}}"
    echo $(queryContainerNetworkSettings "HostPort" "${container_name}" "${org}" "${domain}")
}


function curlItGet() {
    local url=$1
    local cdata=$2
    local wtoken=$3
    res=$(curl -sw "%{http_code}" "${url}" -d "${cdata}" -H "Content-Type: application/json" -H "Authorization: Bearer ${wtoken}")
    local http_code="${res:${#res}-3}" #only 3 last symbols
    if [ ${#res} -eq 3 ]; then
        body=""
    else
        body="${res:0:${#res}-3}" #everything but the 3 last symbols
    fi
    echo "$body $http_code"
}


function generateMultipartBoudary() {
    echo -n -e "--FabricStarterTestBoundary"$(date | md5sum | head -c 10)
}


function generateMultipartHeader() { #expecting boundary and filename as args
    local multipart_header='----'${1}'\r\nContent-Disposition: form-data; name="file"; filename="'
    local multipart_header+=${2}'"\r\nContent-Type: "application/zip"\r\n\r\n'
    echo -n -e  ${multipart_header}
}


function generateMultipartTail() { #expecting boundaty as an arg
    local boundary=${1}
    
    local multipart_tail='\r\n\r\n----'
    local multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n----'
    local multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n----'
    local multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n----'
    local multipart_tail+=${boundary}'--\r\n'
    echo -n -e "${multipart_tail}"
}


function restquery {
    local org=${1}
    local path=${2}
    local query=${3}
    local jwt=${4}
    
    local api_ip=$(getOrgIp "${org}")
    local api_port=$(getOrgContainerPort  "${org}" "${API_NAME}" "${DOMAIN}")
    
    
    curlItGet "http://${api_ip}:${api_port}/${path}" "${query}" "${jwt}"
}


function getJWT() {
    local org=${1}
    
    restquery ${org} "users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}" ""
}


function APIAuthorize() {
    result=($(getJWT ${1}))
    
    local jwt=${result[0]//\"/} #remove quotation marks
    local jwt_http_code=${result[1]}
    echo "Got JWT: ${jwt}" | printLog
    echo "${jwt}"
    
    setExitCode [ "${jwt_http_code}" = "200" ]
    printResultAndSetExitCode "JWT token obtained." > ${SCREEN_OUTPUT_DEVICE}
    
}


function createChannelAPI_() {
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
    
    setExitCode [ "${create_http_code}" = "200" ]
}

function joinChannelAPI_() {

    local channel=${1}
    local org=${2}
    local jwt=${3}
    
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local result=$(restquery ${2} "channels/${channel}" "{\"waitForTransactionEvent\":true}" "${jwt}")  2>${TMP_LOG_FILE}
    printDbg $result > ${SCREEN_OUTPUT_DEVICE}
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    echo ${result}
}


function joinChannelAPI() {
#    ${TEST_CHANNEL_NAME} ${ORG} ${JWT}
    local channel=${1}
    local org=${2}
    local jwt=${3}
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local result=($(joinChannelAPI_ "${channel}" "${org}" "${jwt}"))

    local create_status=$(echo -n ${result[0]} | jq '.[0].status + .[0].response.status' 2>${TMP_LOG_FILE})
    
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    
    local state=$(DeleteSpacesLineBreaks "${create_status}")
    local create_http_code=${result[1]}
    
    setExitCode [ "${create_http_code}" = "200" ]
}



function addOrgToChannel_(){
    local result=$(restquery "${2}" "channels/${TEST_CHANNEL_NAME}/orgs" "{\"orgId\":\"${org2}\",\"waitForTransactionEvent\":true}" "${jwt}")  2>${TMP_LOG_FILE}
    printDbg $result > ${SCREEN_OUTPUT_DEVICE}
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    echo ${result}
}


function addOrgToChannel() {
    local channel=${1}
    local org=${2}
    local jwt=${3}
    local org2=${4}
    
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local result=($(addOrgToChannel_ "${channel}" "${org}" "${jwt}" "${org2}"))
    local create_status=$(echo -n ${result[0]} | jq '.[0].status + .[0].response.status' 2>${TMP_LOG_FILE})
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    
    local state=$(DeleteSpacesLineBreaks "${create_status}")
    local create_http_code=${result[1]}
    
    setExitCode [ "${create_http_code}" = "200" ]
}


function queryPeer() {
    local channel=${1}
    local org=${2}
    local domain=${3}
    local query=${4}
    local subquery=${5:-.}
    
    
    TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    
    local result=$(docker exec cli.${org}.${domain} /bin/bash -c \
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
    local domain=${3}
    local result=$(queryPeer ${channel} ${org} ${domain} '.data.data[0].payload.header.channel_header' '.channel_id')
    
    setExitCode [ "${result}" = "${channel}" ]
}


function runInFabricDir() {
    pushd ${FABRIC_DIR} >/dev/null
    
    local TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local exit_code
    
    eval "$@" > "${TMP_LOG_FILE}"; exit_code=$?
    
    cat "${TMP_LOG_FILE}" | printDbg
    popd >/dev/null
    
    setExitCode [ "${exit_code}" = "0" ]
}


function guessDomain() {
    echo $(docker ps --filter 'ancestor=hyperledger/fabric-orderer' --format "table {{.Names}}" | tail -n+2 | sed -e 's/orderer\.//')
}

function vbox_guessDomain() {
    echo $(docker-machine ls -q  | tail -n+1 | head -n+1 | cut -d '.' -f 2,3)
}


function guessOrgs() {
    local domain=$(guessDomain)
    
    docker ps --format "table {{.Names}}" | \
    tail -n+2 | sed -e 's/orderer\.//' | \
    grep "${domain}" | sed -e "s/${domain}//" | \
    grep -v peer0 | cut -d '.' -f 2 \
    | sort | uniq | egrep '[a-z]' | xargs -I {} echo -n {}" "| sed -e 's/ $//'
}


function vbox_guessOrgs() {
    local domain=$(vbox_guessDomain)
    
    docker-machine ls -q  | grep "${domain}" | cut -d '.' -f1  | xargs -I {} echo -n {}" "| sed -e 's/ $//'
}

main $@