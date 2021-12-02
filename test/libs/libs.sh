#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && LIBDIR=$(dirname ${BASH_SOURCE[0]}) || [ -n $BASH_SOURCE ] && LIBDIR=$(dirname ${BASH_SOURCE[0]}) || LIBDIR=$(dirname $0)

main() {
    export FABRIC_DIR=${FABRIC_DIR:-$(getFabricStarterPath $(pwd))}
    export TEST_ROOT_DIR=${FABRIC_DIR}/test
    export TEST_LAUNCH_DIR=${TEST_LAUNCH_DIR:-${TEST_ROOT_DIR}}
    export TIMEOUT_CHAINCODE_INSTANTIATE=${TIMEOUT_CHAINCODE_INSTANTIATE:-150}

    export PEER_NAME=${PEER_NAME:-peer0}
    export API_NAME=${API_NAME:-api}
    export CLI_NAME=${CLI_NAME:-cli}

    export TEST_CHAINCODE_DIR='test'
    export FABRIC_MAJOR_VERSION=${FABRIC_VERSION%%.*}
    export FABRIC_MAJOR_VERSION=${FABRIC_MAJOR_VERSION:-1}

    export VERSIONED_CHAINCODE_PATH='/opt/chaincode'
    if [ ${FABRIC_MAJOR_VERSION} -ne 1 ]; then # temporary skip v1, while 1.x chaincodes are located in root
        export VERSIONED_CHAINCODE_PATH="/opt/chaincode/${FABRIC_MAJOR_VERSION}x"
    fi

    pushd ${FABRIC_DIR} > /dev/null
    source ./lib/util/util.sh
    source ./lib.sh
    popd > /dev/null
    
    export FSTEST_LOG_FILE="${TEST_LAUNCH_DIR}/fs_network_test.log"
    
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


function checkArgsPassed() {
    shift 
    local args_req=${1}
    shift 2
    local args_passed=( "$@" )

    printDbg "${WHITE}${BRIGHT}checkArgsPassed: Args required: $args_req ${NORMAL}"
    printDbg "Arguments passed: ${args_passed[@]}"

    local num_args_passed="${#args_passed[@]}"

    IFS=',' read -r -a args_required <<< "${args_req}"

    printDbg "Arguments required: ${args_required[@]}"

    local num_args_required="${#args_required[@]}"


    printDbg "checkArgsPassed: args required: ${num_args_required} ${args_required[@]} args passed: ${num_args_passed} ${args_passed[@]}"
    
      if [ ${num_args_required} -gt ${num_args_passed} ];
      then
           printError "\nRequired arguments: ${WHITE}${BRIGHT}${args_req}"
           exit 1
      fi
}


function arrayStartIndex() { #bash starts with 0, zhs starts with 1
    local array
    
    array=(1 0)
    echo ${array[1]}
}


function DeleteSpacesLineBreaks() {
    echo "${1}"| sed -E -e 's/\n|\r|\s//g'
}


function getRandomChannelName() {
    echo testchannel"${RANDOM}"
}


function setExitCode() {
    local errorCode
    
    eval "${@}" 2>/dev/null
    errorCode=$?
    printDbg "setExitCode: ${errorCode}"
    return ${errorCode}
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
    #    export  BLINK=$(tput blink)
    export  REVERSE=$(tput smso)
    export  UNDERLINE=$(tput smul)
}


function printNoColors() {   #filter out set color terminal commands
    local line
    
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
        done
    else
        echo  "$@" | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
    fi
}

function setColorOnError() {
    local error=${1}
    case "$error" in
        0)
            echo "${GREEN}${BRIGHT}"
        ;;
        *)
            echo "${RED}${BRIGHT}"
        ;;
    esac
}

function getFabricStarterPath() {
    local dirname=${1}
    local libpath
    
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
    local exitCode=$?
    local outputdev
    local line
    
    if [[ "$DEBUG" = "false" ]]; then
        outputdev=/dev/null
    else
        outputdev=/dev/stderr
    fi
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE} > ${outputdev}
        done
    else
        echo "$@" | tee -a ${FSTEST_LOG_FILE} > ${outputdev}
    fi
    return ${exitCode}
}


function printLog() {
    
    local line
    
    if (( $# == 0 )) ; then
        while read -t 1 -r line ; do
            echo "${line}" | cat >> ${FSTEST_LOG_FILE}
        done
    else
        echo "$@" | cat >> ${FSTEST_LOG_FILE}
    fi
}


function printToLogAndToScreenCyan() {
    local line
    
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        printInColor "1;36" "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}


function printToLogAndToScreenBlue() {
    local line
    
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        printInColor "1;35" "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}


function printNSymbols() {
    local string=$1
    local num=$2
    local res
    
    res=$(printf "%-${num}s" "$string")
    echo "${res// /"${string}"}"
}


function printNSpaces() {
    local count=0
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
    
    local plainString
    local fullLength
    local symbolLength
    local spaces
    
    plainString=$(printNoColors $string)
    fullLength=${#string}
    symbolLength=${#plainString}
    spaces=$(( fullLength - symbolLength - shifter))
    
    echo "$(printNSpaces ${spaces})""${string2}"
}


function printYellowBox() {
    local length
    local indent
    local boundary
    local indentation
    
    length=$(expr length "$@")
    indent=10
    boundary=$(printNSymbols '=' $((length + $indent * 2)) )
    indentation=$(printNSymbols ' ' $indent )
    
    printYellow "\n${boundary}\n${indentation}$@\n${boundary}\n"
}


function printExitCode() {
    local message=${2:-"Exit code:"}
    if [ "$1" = "0" ]; then printGreen "${message} $1"; else printError "${message} $1"; fi
}


function printToLogAndToScreen() {
    local line
    
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        echo "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}


function printErrToLogAndToScreen() {
    local line
    
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
    local errorCode=${3:-$?}
    if [ ${errorCode} -eq ${2:-0} ]
    then
        printGreen "OK: ${1}" | printToLogAndToScreen
        exit 0
    else
        if [ "${NO_RED_OUTPUT}" = true ]; then
            printGreen "Exit code: ${errorCode}" | printErrToLogAndToScreen
        else
            printError "ERROR! Exit code: ${errorCode}" | printErrToLogAndToScreen
        fi
        exit 1
    fi
}

#__________________________________ API-related functions ___________________________________________

function queryContainerNetworkSettings() {
    local parameter="${1}" # [HostPort|HostIp]
    local container="${2}"
    local organization="${3}"
    local domain="${4}"
    local TMP_LOG_FILE
    local query
    local result

    TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    query='.[0].NetworkSettings.Ports[] | select(. != null)[0].'"${parameter}"''

    result=$(docker inspect ${container}.${organization}.${domain} | jq -r "${query}" 2>${TMP_LOG_FILE});
    echo  "queryContainerNetworkSettings returns:" ${result} | printLog
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    echo $result
}


function getContainerPort() {
    local org="${1:?Org name is required}"
    local containerName="${2:?Container name is required}"
    local domain="${3:-${DOMAIN:?Domain is required}}"
    echo $(queryContainerNetworkSettings "HostPort" "${containerName}" "${org}" "${domain}")
}


function generateMultipartBoudary() {
    echo -n -e "--FabricStarterTestBoundary"$(date | md5sum | head -c 10)
}


function generateMultipartHeader() { # Compose header for curl to send archived chaincode
    local boundary=${1}
    local filename=${2}
    
    local multipart_header
    
    multipart_header='----'${boundary}'\r\nContent-Disposition: form-data; name="file"; filename="'
    multipart_header+=${filename}'"\r\nContent-Type: "application/zip"\r\n\r\n'
    echo -n -e  ${multipart_header}
}


function generateMultipartTail() { # Compose header for curl to send archived chaincode
    local boundary=${1}
    
    local multipart_tail
    
    multipart_tail='\r\n\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n----'
    multipart_tail+=${boundary}'--\r\n'
    echo -n -e "${multipart_tail}"
}


function curlRequest() {
    local url=$1
    local cdata=$2
    local wtoken=$3
    local curlTimeout=${4:-15}

    local res
    local exitCode
    local body
    local httpStatusCode
    res=$(curl --max-time ${curlTimeout} -sw "%{http_code}" "${url}" -X POST -d "${cdata}" -H "Content-Type: application/json" -H "Authorization: Bearer ${wtoken}")
    exitCode=$?

    echo "${RED}curlRequest: (curl exit code: $exitCode) ${NORMAL}" | printDbg
    echo "curlGetIt got _ ${res} _ result" | printDbg
    httpStatusCode="${res:${#res}-3}" #only 3 last symbols
    if [ ${#res} -eq 3 ]; then
        body='{"empty":"true"}'
        echo "body is empty (set to ${body}), code is $httpStatusCode" | printDbg
    else
        body="${res:0:${#res}-3}" #everything but the 3 last symbols
        echo "body is $body, code is $httpStatusCode" | printDbg
    fi
    echo "$body $httpStatusCode"
    return ${exitCode}
}


function restQuery() {
    local org=${1}
    local path=${2}
    local query=${3}
    local jwt=${4}
    local curlTimeout=${5}

    local api_ip
    local api_port

    api_ip=$(getOrgIp "${org}")
    api_port=$(getOrgContainerPort  "${org}" "${API_NAME}" "${DOMAIN}")

    echo  restQuery:  curlRequest "http://${api_ip}:${api_port}/${path}" "${query}" "${jwt}" "${curlTimeout}" | printDbg
    curlRequest "http://${api_ip}:${api_port}/${path}" "${query}" "${jwt}" "${curlTimeout}"
}


restAPIWrapper() {
    
    local TMP_LOG_FILE
    local result
    local exitCode
    local apiStatusCode
    local state
    local httpStatusCode
    
    TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    result=$(restQuery $@)  2>${TMP_LOG_FILE}
    exitCode=$?

    printDbg "restAPIWrapper: exit code:: ${exitCode} result:: ${result[@]}" 
    
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    
    httpStatusCode="${result:${#result}-3}"
    httpStatusCode=${httpStatusCode:0:1}

    printDbg "${WHITE}${UNDERLINE}exitCode: $exitCode  httpStatusCode: ${httpStatusCode}xx ${NORMAL}"

    setExitCode [ "${httpStatusCode}" = "2" ] && [ "${exitCode}" = "0" ]
}


function getJWT() {
    local org=${1}
    restQuery ${org} "users" "{\"username\":\"${API_USERNAME:-user4}\",\"password\":\"${API_PASSWORD:-passw}\"}" ""
}


function APIAuthorize() {
    local org=${1}

    local result
    local jwt
    local httpStatusCode

    result=$(getJWT ${org})

    jwt=${result[$(arrayStartIndex)]//\"/} #remove quotation marks
    jwt="${jwt:0:${#jwt}-3}"
    httpStatusCode="${result:${#result}-3}"
    
    echo "Got JWT: ${jwt} with http status code ${httpStatusCode}" | printDbg
    echo "${jwt}"
    
    setExitCode [ "${httpStatusCode}" = "200" ]
    printResultAndSetExitCode "JWT token obtained." > ${SCREEN_OUTPUT_DEVICE}
}


function createChannelAPI() {
    local channel=${1}
    local org=${2}
    local jwt=${3} 

    restAPIWrapper ${org} "channels" "{\"channelId\":\"${channel}\",\"waitForTransactionEvent\":true}" "${jwt}"
}


function getConsortiumMembers() {
    #TODO: now returns noting
    local org=${1}
    local jwt=${2}

    restQuery ${org} "consortium/members" "{\"waitForTransactionEvent\":true}" "${jwt}"
}

function inviteOrgToDefaultConsortiumAPI() {
    local org=${1}
    local orgToInvite=${2}
    local jwt=${3}

    restAPIWrapper ${org} "consortium/members" "{\"orgId\":\"${orgToInvite}\",\"orgIp\":\"\",\"wwwPort\":\"\",\"waitForTransactionEvent\":true}" "${jwt}"
}

function addOrgToChannelAPI() {
    local channel=${1}
    local org=${2}
    local jwt=${3}
    local orgToAdd=${4}

    local orgIP=$(getOrgIp "${orgToAdd}")
    setCurrentActiveOrg ${orgToAdd}
        local peerPort=$(getContainerPort ${orgToAdd} ${PEER_NAME} ${DOMAIN})
    unsetActiveOrg
    restAPIWrapper "${org}" "channels/${channel}/orgs" "{\"orgId\":\"${orgToAdd}\",\"orgIp\":\"\",\"peerPort\":\"${peerPort}\",\"wwwPort\":\"\",\"waitForTransactionEvent\":true}" "${jwt}"
}

function joinChannelAPI() {
    local channel=${1}
    local org=${2}
    local jwt=${3}
    
    restAPIWrapper ${org} "channels/${channel}" "{\"waitForTransactionEvent\":true}" "${jwt}" 300
}


function installZippedChaincodeAPI() {
    local channel=${1}
    local org=${2}
    local jwt=${3}
    
    local zip_file_path
    local boundary
    local multipart_header
    local multipart_tail
    local tmp_out_file
    local api_ip
    local api_port
    local res
    local httpStatusCode
    local body
    local exitCode
    
    zip_file_path=$(createChaincodeArchiveAndReturnPath ${channel})
    boundary=$(generateMultipartBoudary)
    multipart_header='----'${boundary}'\r\nContent-Disposition: form-data; name="file"; filename="'
    multipart_header+=${zip_file_path}'"\r\nContent-Type: "application/zip"\r\n\r\n'
    
    multipart_tail='\r\n\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n----'
    multipart_tail+=${boundary}'\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n----'
    multipart_tail+=${boundary}'--\r\n'
    
    tmp_out_file=$(tempfile);
    trap "rm -f ${tmp_out_file}" EXIT;
    
    api_ip=$(getOrgIp "${org}")
    api_port=$(getOrgContainerPort  "${org}" "${API_NAME}" "${DOMAIN}")
    trap "rm -f ${zip_chaincode_path}" EXIT;
    
    # Composing single binary file to POST via API
    echo -n -e "${multipart_header}" > "${tmp_out_file}"
    cat   "${zip_file_path}" >> "${tmp_out_file}"
    echo -n -e "${multipart_tail}" >> "${tmp_out_file}"
    
    
    res=$(curl http://${api_ip}:${api_port}/chaincodes \
        -sw ":%{http_code}" \
        -H "Authorization: Bearer ${jwt}" \
        -H 'Content-Type: multipart/form-data; boundary=--'${boundary} \
    --data-binary @"${tmp_out_file}" )
    exitCode=$?
    
    httpStatusCode=$(echo "${res}" | cut -d':' -f 3)
    body='"'$(echo "${res}" | cut -d':' -f 1,2)'"'
    
    echo ${httpStatusCode} | printDbg
    printDbg ${body}
    
    httpStatusCode=${httpStatusCode:0:1}
    setExitCode [ "${httpStatusCode}" = "2" ] && [ ${exitCode} = "0" ]
}


function instantiateTestChaincodeAPI() {
    
    local channel=${1}
    local org=${2}
    local jwt=${3}
    local curlTimeout=${4:-${TIMEOUT_CHAINCODE_INSTANTIATE}}
    local chaincode_name

    chaincode_name=$(getTestChaincodeName ${channel})

    restAPIWrapper ${org} "channels/${channel}/chaincodes" "{\"channelId\":\"${channel}\",\"chaincodeId\":\"${chaincode_name}\",\"waitForTransactionEvent\":true,\"chaincodeType\":\"node\",\"chaincodeVersion\":\"1.0\"}" "${jwt}" ${curlTimeout}
}


invokeTestChaincodeAPI() {
    local channel=${1}
    local org=${2}
    local chaincode_name=${3}
    local jwt=${4}

    restAPIWrapper ${org} "channels/${channel}/chaincodes/${chaincode_name}" "{\"fcn\":\"put\",\"args\":[\"${channel}\",\"${channel}\"],\"waitForTransactionEvent\":true}" "${jwt}"
}

# --------------------------------------------------------------CLI-----------------------------------------------------

function runCLIPeer() {
    local org=${1}
    local domain=${2}
    local command=${@:3}

    local script_dir="${BASEDIR}/.."
    local script_name="run-cli-peer.sh"
    local exit_code

    printDbg "Run '${command}' in cli.peer.${org}.${domain}"

    result=$("${script_dir}/${script_name}" ${org} ${domain} "${command}")
    exit_code=${?}

    set -f
    IFS=''
      echo ${result}
    set +f
    setExitCode [ ${exit_code} = 0 ]
}


function ListPeerChannels() {
    

    local org=${1}
    local domain=${2}
    local result
    local TMP_LOG_FILE

    TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    #result=$(${BASEDIR}/../run-cli-peer.sh ${org} ${domain} peer channel list -o \$ORDERER_ADDRESS \$ORDERER_TLSCA_CERT_OPTS)
    result=$(runCLIPeer ${org} ${domain} peer channel list -o \$ORDERER_ADDRESS \$ORDERER_TLSCA_CERT_OPTS)
    #cat "${TMP_LOG_FILE}" | printDbg
    set -f
    IFS=
    printDbg "Channels ${org} has joined to: ${result}" >/dev/tty
    echo ${result}
    set +f
}


function getCurrentChaincodeName() {
    echo ${CHAINCODE_PREFIX:-reference}
}

function getDockerGatewayAddress() {
    echo $(docker network inspect bridge | jq -r '.[].IPAM.Config | .[].Gateway')
}


function getTestChaincodeName() {
    local channel=${1}
    echo ${CHAINCODE_PREFIX:-$(getCurrentChaincodeName)}_${channel}
}


function verifyOrgJoinedChannel() {
    local channel=${1}
    local org=${2}
    local domain=${3}
    local result

    result=$(ListPeerChannels ${org} ${domain} | tr -d "\r"| grep -E "^${channel}$")
    set -f
    IFS=
      printDbg "Result: ${result}"
    set +f

    setExitCode [ "${result}" = "${channel}" ]
}


function queryPeer() {
    local channel=${1}
    local org=${2}
    local domain=${3}
    local query=${4}
    local subquery=${5:-.}
    
    local TMP_LOG_FILE
    local result

    TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;

    #result=$(${BASEDIR}/../run-cli-peer.sh ${org} ${domain} peer channel fetch config /dev/stdout -o \$ORDERER_ADDRESS -c ${channel} \$ORDERER_TLSCA_CERT_OPTS 2\>/dev/null \| configtxlator proto_decode --type \"common.Block\" 2\>/dev/null)
    result=$(runCLIPeer ${org} ${domain} peer channel fetch config /dev/stdout -o \$ORDERER_ADDRESS -c ${channel} \$ORDERER_TLSCA_CERT_OPTS 2\>/dev/null \| configtxlator proto_decode --type \"common.Block\" 2\>/dev/null)
    printDbg "Query: ${query}"
    printDbg "Subquery: ${subquery}"
    result=$(echo "${result}" | jq ${query} |  jq -r ${subquery}   2>"${TMP_LOG_FILE}")
    printDbg "Parse result: $result"
    echo $result
}


function verifyChannelExists() {
    local channel=${1}
    local org=${2}

    local result
    
    result=$(queryPeer ${channel} ${org} ${DOMAIN} '.data.data[0].payload.header.channel_header' '.channel_id')
    printDbg "Expect: ${channel}, got: ${result}"
    
    setExitCode [ "${result}" = "${channel}" ]
}


function verifyOrgIsInChannel() {
    local channel=${1}
    local org=${2}
    local org2=${3}
    local domain=${4:-$DOMAIN}

    local result
    printDbg "Channel: ${channel} Org: ${org} Org2: ${org2} Domain: ${domain}"
    result=$(queryPeer ${channel} ${org} ${domain} ".data.data[0].payload.data.config.channel_group.groups.Application.groups.${org2}.values.MSP.value" '.config.name')
    printDbg "${result}"
    
    setExitCode [ "${result}" = "${org2}" ]
}


function runInFabricDir() {
    local TMP_LOG_FILE
    local exitCode
    
    pushd ${FABRIC_DIR} >/dev/null
    
    TMP_LOG_FILE=$(tempfile); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    
    printDbg eval "$@"
    eval "$@" > "${TMP_LOG_FILE}";
    exitCode=$?
    
    cat "${TMP_LOG_FILE}" | printDbg
    popd >/dev/null
    
    setExitCode [ "${exitCode}" = "0" ]
}


function copyTestChiancodeCLI() {
    local channel=${1}
    local org=${2}
    local domain=${3}
    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    local chaincode_name=${4:-"${chaincode_init_name}_${channel}"}
    local lang=${5:-"node"}
    local chaincode_dir=${6:-"${VERSIONED_CHAINCODE_PATH}/${lang}/reference"}

    local result
    local exitCode

    result=$(runCLIPeer ${org} ${domain} \
        "mkdir -p ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincode_name};  \
          cp -R ${chaincode_dir}/* \
          ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincode_name}")
    exitCode=$?
    printDbg "Result: ${result}"

    setExitCode [ "${exitCode}" = "0" ]
}

function installTestChiancodeCLI() {
    local channel=${1}
    local org=${2}
    local domain=${3}
    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    local chaincode_name=${4:-"${chaincode_init_name}_${channel}"}
    local lang=${5:-"node"}

    local result
    local exitCode

    result=$(runCLIPeer ${org} ${domain} \
    "./container-scripts/network/chaincode-install.sh '${chaincode_name}' 1.0 ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincode_name}" ${lang} 2>&1)
    local exitCode=$?
    printDbg "Result: ${result}"

    setExitCode [ "${exitCode}" = "0" ]
}



#function ListPeerChaincodes() {
#    local channel=${1}
#    local org2_=${2}
#    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
#
#    local result
#    local exitCode
#
#    pushd ${FABRIC_DIR} > /dev/null
#
#    result=$(runCLI "peer lifecycle chaincode queryinstalled")
#    exitCode=$?
#
#    popd > /dev/null
#    printDbg "${result}"
#    set -f
#    IFS=
#    echo "${result}" | grep Label
#    set +f
#
#    setExitCode [ "${exitCode}" = "0" ]
#}


#function ListPeerChaincodesInstantiated() {
#    local channel=${1}
#    local org2_=${2}
#    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
#
#    local result
#    local exitCode
#
#    pushd ${FABRIC_DIR} > /dev/null
#
#    result=$(ORG=${org2_} runCLI "peer lifecycle chaincode querycommitted -C '${channel}'")
#    exitCode=$?
#
#    popd > /dev/null
#
#    printDbg "${result}"
#
#    set -f
#    IFS=
#    echo ${result}
#    set +f
#
#    setExitCode [ "${exitCode}" = "0" ]
#}

#function getChaincodeListFromPeer2x() {
#    local channel=${1}
#    local org=${2}
#
#    echo $(ListPeerChaincodes ${channel} ${org}| grep Label | cut -d':' -f 2 | sed -e 's/\s//g' | grep -E "^${chaincode_name}_")
#}
#
#function cutChaincodeNameFromPeer2x() {
#    local chaincode_string=${1}
#    echo $chaincode_string | rev | cut -d '_' -f 2- | rev
#}

#function verifyChiancodeInstalled() {
#    local channel=${1}
#    local org=${2}
#
#    local chaincode_init_name
#    local chaincode_name
#    local chaincode_list
#    local result
#
#    chaincode_init_name=${CHAINCODE_PREFIX:-reference}
#    chaincode_name=${chaincode_init_name}_${channel}
#    chaincode_list=$(getChaincodeListFromPeer2x $channel $org)
#    result=$(cutChaincodeNameFromPeer2x $chaincode_list)
#    printDbg "Result: ${result}"
#
#    setExitCode [ "${result}" = "${chaincode_name}" ]
#}

function verifyChiancodeInstalled() {
    local channel=${1}
    local org=${2}
    local domain=${3}
    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    local chaincode_name=${4:-${chaincode_init_name}_${channel}}

    local chaincode_name
    local result


    result=$(runCLIPeer ${org} ${domain} listChaincodesInstalled ${channel} ${org} ${domain} 2>/dev/null)
    #result=$(runCLIPeer ${org} ${domain} peer lifecycle chaincode queryinstalled --output json)
    #peer lifecycle chaincode queryinstalled --output json
    set -f
    IFS=
    printDbg "Result: ${result}"
    result=$(echo $result | tr -d "\r" | grep -E "^$chaincode_name$")
    set +f
    setExitCode [ "${result}" = "${chaincode_name}" ]
}

function verifyChiancodeInstantiated() {
    local channel=${1}
    local org=${2}
    local domain=${3}
    local chaincode_init_name=${CHAINCODE_PREFIX:-reference}
    local chaincode_name=${4:-${chaincode_init_name}_${channel}}
    local result


    result=$(runCLIPeer ${org} ${domain} listChaincodesInstantiated ${channel} ${org} 2>/dev/null)
    set -f
    IFS=
    printDbg "Result: ${result}"
    result=$(echo $result  | tr -d "\r" | grep -E "^$chaincode_name")
    set +f

    setExitCode [ "${result}" = "${chaincode_name}" ]
}


function createChaincodeArchiveAndReturnPath() {
    local channel=${1}

    local chaincode_name=$(getTestChaincodeName ${channel})
    local chaincode_init_name=$(getCurrentChaincodeName)
    local chaincode_file_name=${chaincode_name}.zip
    local zip_chaincode_path="/tmp/${chaincode_file_name}"
    
    pushd ${FABRIC_DIR}/chaincode/node/ >/dev/null
    mkdir ${chaincode_name}
    cp ${FABRIC_DIR}/chaincode/node/${chaincode_init_name}/* ${FABRIC_DIR}/chaincode/node/${chaincode_name}
    cd ${FABRIC_DIR}/chaincode/node/ && zip -r ${zip_chaincode_path} ./${chaincode_name}/* | printDbg
    echo "Chaincode archive created:  $(ls -la ${zip_chaincode_path})" | printDbg
    rm -rf ${FABRIC_DIR}/chaincode/node/${chaincode_name}
    popd >/dev/null
    
    echo "${zip_chaincode_path}" | printDbg
    echo "${zip_chaincode_path}"
    if [ ! -e "${zip_chaincode_path}" ];
    then
        exit 1
    fi
}


function instantiateTestChaincodeCLI() {
    local channel=${1}
    local org=${2}
    local domain=${DOMAIN}
    local chaincode_name=${3:-$(getTestChaincodeName ${channel})}
    
    local result
    local exitCode
    
    reuslt=$(runCLIPeer ${org} ${domain} ./container-scripts/network/chaincode-instantiate.sh ${channel} ${chaincode_name} 2>&1 | printDbg)
    exitCode=$?
    printDbg "${result}"

    setExitCode [ "${exitCode}" = "0" ]
}


function guessDomain() {
    echo $(docker ps --filter 'ancestor=hyperledger/fabric-orderer' --format "table {{.Names}}" | tail -n+2 | sed -e 's/orderer\.//')
}


function vboxGuessDomain() {
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


function vboxGuessOrgs() {
    local domain=$(vboxGuessDomain)
    
    docker-machine ls -q  | grep "${domain}" | cut -d '.' -f1  | xargs -I {} echo -n {}" "| sed -e 's/ $//'
}


function checkContainersExist() {
    local org=${1}
    local orgDomain=${2}
    shift; shift
    local containersList=${@}
    
    local presence
    local container
    local exitCode=true
    
    setCurrentActiveOrg ${org}
    for container in ${containersList[@]}; do
        printDbg "docker ps -q -f \"name=${container}.${orgDomain}\""
        presence=$(docker ps -q -f "name=${container}.${orgDomain}")
        if [ -z "${presence}" ]; then
            printDbg "${BRIGHT}${RED}Container not running: ${container}${NORMAL}"
            exitCode=false
        fi
    done
    setExitCode ${exitCode}
}

function containerNameString() {
    local service=${1}
    local org=${2}
    local domain=${3}

    echo ${service}.${org}.${domain}
}

function dockerMakeDirInContainer() {
    local container="${1:?Container name is required}"
    local path="${2:?Directory path is required}"
    docker container exec -it ${container} mkdir -p "${path}"
}

function dockerCopyDirToContainer() {
    local service="${1}"
    local org=${2}
    local domain=${3}
    local sourcePath="${4:?Source path is required}"
    local destinationPath="${5:?Destination path is required}"
    local container=$(containerNameString ${service} ${org} ${domain})
    local container_home_dir
    local parent_dir
    local container

    eval $(connectOrgMachine "${org}")
    dockerMakeDirInContainer ${container} "${destinationPath}"
    container_home_dir=$(echo $(docker container exec -it ${container} pwd) | tr -d '\r')'/'
    parent_dir=$(if [[ ${destinationPath} != /* ]]; then echo ${container_home_dir}; fi)
    echo "docker cp ${sourcePath} ${container}:${parent_dir}${destinationPath}"
    docker cp ${sourcePath} ${container}:"${parent_dir}${destinationPath}"
    docker container exec -it ${container} ls -la "${parent_dir}${destinationPath}" >/dev/null
    setExitCode [[ $? == 0 ]]
}

main $@
