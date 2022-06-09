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
        export WGET_CMD="wget -P"
        export BASE64_UNWRAP_CODE="| tr -d '\n'"
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
    local argsReq=${1}
    shift 2
    local argsPassed=( "$@" )

    printDbg "${WHITE}${BRIGHT}checkArgsPassed: Args required: $argsReq ${NORMAL}"
    printDbg "Arguments passed: ${argsPassed[@]}"

    local numArgsPassed="${#argsPassed[@]}"

    IFS=',' read -r -a argsRequired <<< "${argsReq}"

    printDbg "Arguments required: ${argsRequired[@]}"

    local numArgsRequired="${#argsRequired[@]}"


    printDbg "checkArgsPassed: args required: ${numArgsRequired} ${argsRequired[@]} args passed: ${numArgsPassed} ${argsPassed[@]}"
    
      if [ ${numArgsRequired} -gt ${numArgsPassed} ];
      then
           printError "\nRequired arguments: ${WHITE}${BRIGHT}${argsReq}"
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

function printColoredText() {
    local color=${1}
    local text=${@:2}

    echo -e "${color}${text}${NORMAL}"
}

function printOK() {
    local line=${@}
    printColoredText "${BRIGHT}${GREEN}" "${line}"
}

function printERR() {
    local line=${@}
    printColoredText "${BRIGHT}${RED}" "${line}"
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

#function printInfo() {
#local border=$(printf -- '*%.0s' {1..80})
#
#echo "${border}"
#for arg in "${@}"; do
#    printColoredText "${BRIGHT}${YELLOW}" "${arg}"
#done
#echo "${border}"
#}

function getFabricStarterPath() {
    local dirName=${1}
    local libPath
    
    libPath=$(realpath "${dirName}"/lib.sh)
    
    if [[ ! -f ${libPath} ]]; then
        dirName=$(realpath "${dirName}"/../)
        getFabricStarterPath ${dirName}
    else
        if [[ $dirName != '/' ]]; then
            echo ${dirName}
        else
            echo "Run tests in fabric-starter directory!"
            setExitCode false
        fi
    fi
}

function absDirPath() {
    local dir="${@}"
    local result
    if [ ! -z "${dir}" ]; then
        result="$(bash -c  "cd ${dir} && pwd")"
        echo "${result}"
    fi
}

function getVarFromEnvFile() {
    local varName=${1}
    local filePath="${2}"

    bash -c "source \"${filePath}\"; echo \${${varName}}"
}

function getOrgConfigFilePath() {
    local org=${1}
    local configDir=${@:2}

    if [ ! -z ${configDir} ]; then
        configDir="$(absDirPath "${configDir}")"

        for file in "${configDir}"/*; do
            [ -e "$file" ] || continue
            orgName=$(getVarFromEnvFile ORG "${file}")
            if [ $orgName == "$org" ]; then
                echo $file
            fi
        done
    fi
}

function getVarFromTestEnvCfg() {
    local var=${1}
    local org=${2}
    local confDirPath="${NETCONFPATH:-3}"

    local confFilePath=$(getOrgConfigFilePath ${org} "${confDirPath}")
    local varValue=$(getVarFromEnvFile ${var} "${confFilePath}")
    echo ${varValue}
}


function getOrgOrdererDomain() {
    local org=${1}

    local ordererDomain=$(getVarFromTestEnvCfg ORDERER_DOMAIN ${org})
    echo ${ordererDomain}
}


function getOrgDomain() {
    local org=${1}

    local domain=$(getVarFromTestEnvCfg DOMAIN ${org})
    echo ${domain}
}

function getWwwPort() {
    local org=${1}

    local WwwPort=$(getVarFromTestEnvCfg WWW_PORT ${org})
    echo ${WwwPort}
}

function getAPIPort() {
    local org=${1}

    local APIPort=$(getVarFromTestEnvCfg API_PORT ${org})
    echo ${APIPort}
}

function getPeerOrgName() {
    local org=${1}

    local peerOrgName=$(getVarFromTestEnvCfg PEEER_ORG_NAME ${org})
    echo ${peerOrgName}
}

function getOrgName() {
    local org=${1}

    local orgName="${org}.$(getOrgDomain ${org})"
    echo ${orgName}
}

function getOrgIPAddress() {
    local org=${1}

    local orgIPAddress=$(getVarFromTestEnvCfg MY_IP ${org})
    echo ${orgIPAddress}
}


function printDbg() {
    local exitCode=$?
    local outputDev
    local line
    
    if [[ "$DEBUG" = "false" ]]; then
        outputDev=/dev/null
    else
        outputDev=/dev/stderr
    fi
    if (( $# == 0 )) ; then
        while read -r line ; do
            echo "${line}" | tee -a ${FSTEST_LOG_FILE} > ${outputDev}
        done
    else
        echo "$@" | tee -a ${FSTEST_LOG_FILE} > ${outputDev}
    fi
    return ${exitCode}
}


function printArgs() {
    for argNo in $(seq 0 $#); do echo "Parameter ${argNo}: ${!argNo}"; done
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


function printToLogAndToScreen() {
    local line

    if (( $# == 0 )) ; then
        while read -r line ; do
            echo -e "${line}" | tee -a ${FSTEST_LOG_FILE}
        done
    else
        echo -e "$@" | tee -a ${FSTEST_LOG_FILE}
    fi
}

function printToLogAndToScreenCyan() {
    local line=${@}
    printColoredText "${BRIGHT}${CYAN}" "${line}" | printToLogAndToScreen
}


function printToLogAndToScreenBlue() {
    local line=${@}
    printColoredText "${BRIGHT}${BLUE}" "${line}" | printToLogAndToScreen
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
    
    printColoredText "${BRIGHT}${YELLOW}" "\n${boundary}\n${indentation}$@\n${boundary}\n"
}


function printExitCode() {
    local message=${2:-"Exit code:"}
    if [ "$1" = "0" ]; then printColoredText "${BRIGHT}${GREEN}" "${message} $1"; else printError "${message} $1"; fi
}


function printResultAndSetExitCode() {

    local currentExitCode=$?

    local message=${1}
    local exitCodeRequired=${2:-0}
    local exitCode=${3:-${currentExitCode}}

    if [ ${exitCode} -eq ${exitCodeRequired} ]
    then
        printOK "OK: ${message}" | printToLogAndToScreen
        setExitCode true
    else
        if [ "${NO_RED_OUTPUT}" = true ]; then
            printOK "Exit code: ${exitCode}" | printToLogAndToScreen
        else
            printError "ERROR! Exit code: ${exitCode}" | printToLogAndToScreen
        fi
        setExitCode false
    fi
}

#__________________________________ API-related functions ___________________________________________
function inspectDockerContainer() {
    local org=${1}
    local fullContainerName=${2}

    setCurrentActiveOrg $org

    result=$(docker inspect ${fullContainerName})
    IFS= echo ${result}
}

function queryContainerNetworkSettings() {
    local parameter="${1}" # [HostPort|HostIp]
    local container="${2}"
    local org="${3}"
    local domain="${4}"


    local TMP_LOG_FILE=$(mktemp); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local query='.[0].NetworkSettings.Ports[] | select(. != null)[0].'"${parameter}"''
    local containerName=$(containerNameString "org" ${container} ${org})

    printDbg "${BRIGHT}${BLUE}Parameter: ${1}, Container: ${2}, Org: ${3}, Domain: ${4}, ContainerName: ${containerName}${NORMAL}"
    connectOrgMachine ${org} ${domain}
    local result=$(docker inspect ${containerName} | jq -r "${query}" 2>${TMP_LOG_FILE});

    echo  "queryContainerNetworkSettings returns:" ${result} | printDbg
    #cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    echo $result
}

function getContainerTCPPortMapping() {
    local port=${1}
    local container="${2}"
    local org="${3}"
    local domain="${4}"

    local TMP_LOG_FILE=$(mktemp); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local containerName=$(containerNameString "org" ${container} ${org})
    local query='.[0].NetworkSettings.Ports | to_entries|.[]|select(.key == "'${port}'/tcp") | [.key, .value[0].HostPort]'
    connectOrgMachine ${org} ${domain}
    local result=$(docker inspect ${containerName} | jq "${query}" | jq -jr '.[]' | sed -e 's|/tcp|\t|' | cut -d$'\t' -f 2 2>${TMP_LOG_FILE});
    cat ${TMP_LOG_FILE} | printDbg > ${SCREEN_OUTPUT_DEVICE}
    echo $result
}


function getContainerTCPReversePortMapping() {
    local port=${1}
    local container="${2}"
    local org="${3}"
    local domain="${4}"

    local TMP_LOG_FILE=$(mktemp); trap "rm -f ${TMP_LOG_FILE}" EXIT;
    local containerName=$(containerNameString "org" ${container} ${org})
    local query='.[0].NetworkSettings.Ports | to_entries|.[]| select(.value[0].HostPort == "'${port}'") | .key'
    connectOrgMachine ${org} ${domain}
    local result=$(docker inspect ${containerName} | jq -r "${query}" | sed -e 's|/tcp|\t|' 2>${TMP_LOG_FILE});
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
    
    local multipartHeader
    
    multipartHeader='----'${boundary}'\r\nContent-Disposition: form-data; name="file"; filename="'
    multipartHeader+=${filename}'"\r\nContent-Type: "application/zip"\r\n\r\n'
    echo -n -e  ${multipartHeader}
}


function generateMultipartTail() { # Compose header for curl to send archived chaincode
    local boundary=${1}
    
    local multipartTail
    
    multipartTail='\r\n\r\n----'
    multipartTail+=${boundary}'\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n----'
    multipartTail+=${boundary}'\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n----'
    multipartTail+=${boundary}'\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n----'
    multipartTail+=${boundary}'--\r\n'
    echo -n -e "${multipartTail}"
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
    printDbg "curl --insecure --max-time ${curlTimeout} -sw \"%{http_code}\" \"${url}\" -X POST -d \"${cdata}\" -H \"Content-Type: application/json\" -H \"Authorization: Bearer ${wtoken}\""
    res=$(curl --insecure --max-time ${curlTimeout} -sw "%{http_code}" "${url}" -X POST -d "${cdata}" -H "Content-Type: application/json" -H "Authorization: Bearer ${wtoken}")
    exitCode=$?

    echo "${CYAN}curlRequest: (curl exit code: $exitCode) ${NORMAL}" | printDbg
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

    local apiIP
    local apiPort

    apiIP=$(getOrgIPAddress "${org}")
    apiPort=$(getAPIPort ${org})

    echo  restQuery:  curlRequest "https://${apiIP}:${apiPort}/${path}" "${query}" "${jwt}" "${curlTimeout}" | printDbg
    curlRequest "https://${apiIP}:${apiPort}/${path}" "${query}" "${jwt}" "${curlTimeout}"
}


function restAPIWrapper() {
    
    local TMP_LOG_FILE
    local result
    local exitCode
    local httpStatusCode
    
    TMP_LOG_FILE=$(mktemp); trap "rm -f ${TMP_LOG_FILE}" EXIT;
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
    local orgIP=$(getOrgIPAddress ${orgToInvite})
    local orgDomain=$(getOrgDomain ${orgToInvite})
    local wwwPort=$(getWwwPort ${orgToInvite})
    local jwt=${3}

    restAPIWrapper ${org} "consortium/members" "{\"orgId\":\"${orgToInvite}\",\"domain\":\"${orgDomain}\",\"orgIp\":\"${orgIP}\",\"wwwPort\":\"${wwwPort}\",\"waitForTransactionEvent\":true}" "${jwt}" 30
}

function getChaincodePackageId() {
    local org=${1}
    local chaincodeName=${2}

    setCurrentActiveOrg ${org}
    local result=$(runCLIPeer ${org} listPackageIDsInstalled)

    IFS= printDbg "jq -r .[][] | {id: .package_id, name: .label} | select(.name==\"${chaincodeName}\") | .id"
    IFS= echo ${result} | jq -r ".[][] | {id: .package_id, name: .label} | select(.name==\"${chaincodeName}\") | .id"
}


function addOrgToChannelAPI() {
    local channel=${1}
    local org=${2}
    local jwt=${3}
    local orgToAdd=${4}

    local orgIP=$(getOrgIPAddress ${orgToAdd})
    local orgDomain=$(getOrgDomain ${orgToAdd})
    local wwwPort=$(getWwwPort ${orgToAdd})

    printDbg "${GREEN}Set current active ORG:${NORMAL}"
    setCurrentActiveOrg ${org}
    printDbg "${GREEN}Get org container port:${NORMAL}"
        local peerPort=$(getContainerPort ${orgToAdd} $PEER_NAME ${orgDomain})

    printDbg "${GREEN}REST API wrapper:${NORMAL}"
    restAPIWrapper "${org}" \
    "channels/${channel}/orgs" \
    "{\"orgId\":\"${orgToAdd}\",\"orgIp\":\"${orgIP}\",\"orgName\":\"$(getOrgName ${orgToAdd})\",\"domain\":\"${orgDomain}\",\"peerPort\":\"${peerPort}\",\"wwwPort\":\"${wwwPort}\",\"waitForTransactionEvent\":true}" \
    "${jwt}"
    unsetActiveOrg
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
    local chaincodeName=${4}
    local version=${5}
    local path=${6}
    local lang=${7}
    printDbg "local packageFilePath=\$(createChaincodeArchiveAndReturnPath ${channel} ${org} ${chaincodeName} ${version} ${path} ${lang})"
    local packageFilePath=$(createChaincodeArchiveAndReturnPath ${channel} ${org} ${chaincodeName} ${version} ${path} ${lang})

    local boundary=$(generateMultipartBoudary)
    local multipartHeader='----'${boundary}'\r\nContent-Disposition: form-data; name="file"; filename="'
    multipartHeader+=${packageFilePath}'"\r\nContent-Type: "application/zip"\r\n\r\n'
    
    local multipartTail='\r\n\r\n----'
    multipartTail+=${boundary}'\r\nContent-Disposition: form-data; name="targets"\r\n\r\n\r\n----'
    multipartTail+=${boundary}'\r\nContent-Disposition: form-data; name="version"\r\n\r\n1.0\r\n----'
    multipartTail+=${boundary}'\r\nContent-Disposition: form-data; name="language"\r\n\r\nnode\r\n----'
    multipartTail+=${boundary}'--\r\n'
    
    local tmpOutFile=$(mktemp);
    trap "rm -f ${tmpOutFile}" EXIT;
    
    local apiIP=$(getOrgIp "${org}")
    local apiPort=$(getAPIPort ${org})

    # Composing single binary file to POST via API
    echo -n -e "${multipartHeader}" > "${tmpOutFile}"
    cat   "${packageFilePath}" >> "${tmpOutFile}"
    echo -n -e "${multipartTail}" >> "${tmpOutFile}"

    local res=$(curl --insecure https://${apiIP}:${apiPort}/chaincodes \
        -sw ":%{http_code}" \
        -H "Authorization: Bearer ${jwt}" \
        -H 'Content-Type: multipart/form-data; boundary=--'${boundary} \
    --data-binary @"${tmpOutFile}" )
    local exitCode=$?
    
    local httpStatusCode=$(echo "${res}" | rev | cut -d':' -f 1 | rev)
    local body='"'$(echo "${res}" | rev | cut -d':' -f 2- | rev)'"'

    echo "HTTP Status code: ${httpStatusCode}" | printDbg
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
    local chaincodePackageId=$(getChaincodePackageId ${org} "${chaincode_name}_1.0")

    printDbg "chaincodePackageId=\$(getChaincodePackageId ${org} "${chaincode_name}_1.0")"
    printDbg "---${chaincodePackageId}---"

    restAPIWrapper ${org} "channels/${channel}/chaincodes" "{\"packageId\":\"${chaincodePackageId}\",\"channelId\":\"${channel}\",\"chaincodeId\":\"${chaincode_name}\",\"waitForTransactionEvent\":true,\"chaincodeType\":\"node\",\"chaincodeVersion\":\"1.0\"}" "${jwt}" ${curlTimeout}
}


invokeTestChaincodeAPI() {
    local channel=${1}
    local org=${2}
    local chaincodeName=${3}
    local jwt=${4}

    restAPIWrapper ${org} "channels/${channel}/chaincodes/${chaincodeName}" "{\"fcn\":\"put\",\"args\":[\"${channel}\",\"${channel}\"],\"waitForTransactionEvent\":true}" "${jwt}"
}

# --------------------------------------------------------------CLI-----------------------------------------------------

function runInFabricDir() {
    local TMP_LOG_FILE
    local exitCode

    pushd ${FABRIC_DIR} >/dev/null

    TMP_LOG_FILE=$(mktemp); trap "rm -f ${TMP_LOG_FILE}" EXIT;

    printDbg eval "$@"
    eval "$@" > "${TMP_LOG_FILE}";
    exitCode=$?

    cat "${TMP_LOG_FILE}" | printDbg
    popd >/dev/null

    setExitCode [ "${exitCode}" = "0" ]
}


function runCLIPeer() {
    local compose_org=${1}
    local command=${@:2}

    local domain=${3:-$(getOrgDomain ${org})}

    local scriptDir="${BASEDIR}/.."
    local scriptName="run-cli-peer.sh"
    local exitCode

    printDbg "Run '${command}' in cli.peer0.${compose_org}.${domain}"

    result=$("${scriptDir}/${scriptName}" ${compose_org} "${command}")
    exitCode=${?}

    IFS= printDbg  "runCLIPeer result: ${result}"
    IFS= echo ${result}
    setExitCode [ ${exitCode} = 0 ]
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

    local result

    result=$(ListPeerChannels ${org} | tr -d "\r"| grep -E "^${channel}$")
    IFS= printDbg "Result: ${result}"
    setExitCode [ "${result}" = "${channel}" ]
}


function copyTestChiancodeCLI() {
    local channel=${1}
    local org=${2}
    local chaincodeInitName=${CHAINCODE_PREFIX:-reference}
    local chaincodeName=${3:-"${chaincodeInitName}_${channel}"}
    local lang=${4:-"node"}
    local chaincodeDir=${5:-"${VERSIONED_CHAINCODE_PATH}/${lang}/reference"}

    local result
    local exitCode

    result=$(runCLIPeer ${org} \
        "mkdir -p ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincodeName};  \
          cp -R ${chaincodeDir}/* \
          ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincodeName}")
    exitCode=$?
    printDbg "Result: ${result}"

    setExitCode [ "${exitCode}" = "0" ]
}

function installTestChiancodeCLI() {
    local channel=${1}
    local org=${2}
    local domain=${3}
    local chaincodeInitName=${CHAINCODE_PREFIX:-reference}
    local chaincodeName=${4:-"${chaincodeInitName}_${channel}"}
    local lang=${5:-"node"}

    local result
    local exitCode

    result=$(runCLIPeer ${org} \
    "./container-scripts/network/chaincode-install.sh '${chaincodeName}' 1.0 ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincodeName} ${lang}" 2>&1)
    local exitCode=$?
    printDbg "Result: ${result}"

    setExitCode [ "${exitCode}" = "0" ]
}

function prepareChaincode() {
    local org=${1}
    local chaincodeInitName=${2}
    local chaincodeName=${3}
    local lang=${4}
    local chaincodeVersion=${5:-'1.0'}
    local path=${6}

    local chaincodeArchiveFilePath=''
    local tmpDir='/tmp'
    local chaincodeSourcePathInContainer="${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincodeName}"

    if [ "${FABRIC_MAJOR_VERSION}" == "2" ]; then
            printDbg "${BIRHT}${CYAN}Create v.2 chaincode package...${NORMAL}"

            copyDirToContainer cli.peer0  ${org} $(getOrgDomain ${org}) "${path}" "${chaincodeSourcePathInContainer}"

            local CC_LABEL=${chaincodeName}_${chaincodeVersion}

            local result=$(runCLIPeer ${org} \
                "peer lifecycle chaincode package ${chaincodeSourcePathInContainer}/../${chaincodeName}.tar.gz --path ${chaincodeSourcePathInContainer}/${chaincodeInitName} --lang $lang --label $CC_LABEL")
            local exitCode=$?
            printDbg "Result: ${result}"

            dockerCopyFileFromContainer cli.peer0 ${org} $(getOrgDomain ${org}) ${chaincodeSourcePathInContainer}/../${chaincodeName}.tar.gz ${tmpDir}
            chaincodeArchiveFilePath=${tmpDir}/${chaincodeName}.tar.gz
    else
       printColoredText "${BIRHT}${CYAN}" "Create v.1 chaincode package..." | printDbg
       local chaincodePackageFilePath="${tmpDir}/${chaincodeName}"
            mkdir ${chaincodePackageFilePath}
            cp -r ${path}/* ${chaincodePackageFilePath}
            pushd ${tmpDir} >/dev/null
            zip -r ${chaincodePackageFilePath}.zip ./${chaincodeName}/* | printDbg
            popd > /dev/null
            chaincodeArchiveFilePath=${chaincodePackageFilePath}.zip
    fi

    echo ${chaincodeArchiveFilePath}
}


function createChaincodeArchiveAndReturnPath() {
    local channel=${1}
    local org=${2}
    local chaincodeName=${3:-$(getTestChaincodeName ${channel})}
    local chaincodeInitName=$(getCurrentChaincodeName)
    local chaincodePackageFileName=${chaincodeName}.zip
    local chaincodePackageFilePath="/tmp/${chaincodePackageFileName}"
    local lang='node'
 #   local chaincodeSourcePathInContainer="${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincodeName}"

    local chaincodePackageFilePath=$(prepareChaincode ${org} ${chaincodeInitName} ${chaincodeName} ${lang} '1.0' "${BASEDIR}/../resources/chaincode/${FABRIC_MAJOR_VERSION}x/${lang}/reference")

    echo "Chaincode archive created:  $(ls -la ${chaincodePackageFilePath})" | printDbg
    rm -rf ${FABRIC_DIR}/chaincode/node/${chaincodeName}

    echo "Path to package file: ${chaincodePackageFilePath}" | printDbg
    echo "${chaincodePackageFilePath}"
    if [ ! -e "${chaincodePackageFilePath}" ];
    then
        setExitCode false
    fi
}


function instantiateTestChaincodeCLI() {
    local channel=${1}
    local org=${2}
    local chaincodeName=${3:-$(getTestChaincodeName ${channel})}
    
    local result=$(runCLIPeer ${org} ./container-scripts/network/chaincode-instantiate.sh ${channel} ${chaincodeName} 2>&1 | printDbg)
    local exitCode=$?

    printDbg "${result}"
    setExitCode [ "${exitCode}" = "0" ]
}

#
#function guessDomain() {
#    echo $(docker ps --filter 'ancestor=hyperledger/fabric-orderer' --format "table {{.Names}}" | tail -n+2 | sed -e 's/orderer\.//')
#}
#
#
#function vboxGuessDomain() {
#    echo $(docker-machine ls -q  | tail -n+1 | head -n+1 | cut -d '.' -f 2,3)
#}
#
#
#function guessOrgs() {
#    local domain=$(guessDomain)
#
#    docker ps --format "table {{.Names}}" | \
#    tail -n+2 | sed -e 's/orderer\.//' | \
#    grep "${domain}" | sed -e "s/${domain}//" | \
#    grep -v peer0 | cut -d '.' -f 2 \
#    | sort | uniq | egrep '[a-z]' | xargs -I {} echo -n {}" "| sed -e 's/ $//'
#}
#
#
#function vboxGuessOrgs() {
#    local domain=$(vboxGuessDomain)
#
#    docker-machine ls -q  | grep "${domain}" | cut -d '.' -f1  | xargs -I {} echo -n {}" "| sed -e 's/ $//'
#}


function checkContainersExist() {
    local containerType=${1}
    local org=${2}
    local containersList=${@:3}
    
    local presence=""
    local container=""
    local exitCode=true
    
    setCurrentActiveOrg ${org}

    for container in ${containersList[@]}; do
        local containerName=$(containerNameString "${containerType}" ${container} ${org})

        printDbg "${BRIGHT}${BLUE}Check container: ${containerName}${NORMAL}"
        printDbg "docker ps | awk '{print \$NF}' | grep -E \"^${containerName}\$\""
        presence=$(docker ps | awk '{print $NF}' | grep -E "^${containerName}$")
        if [ -z "${presence}" ]; then
            printDbg "${BRIGHT}${RED}Container not running:  ${containerName}${NORMAL}"
            exitCode=false
        fi
    done
    setExitCode ${exitCode}
}

function containerNameString() {
    local containerType=${1}
    local service=${2}
    local org=${3}

    local domain=$(getOrgDomain ${org})
    local orgComponent=".${org}"

    if [ "${containerType}" == "orderer" ]; then
        orgComponent=""
    fi

    if [ "${service}" == 'peer0' ]; then
        local confFilePath=$(getOrgConfigFilePath ${org} ${NETCONFPATH})
        local peerAddrPrefix=$(getVarFromEnvFile PEER_ADDRESS_PREFIX "${confFilePath}")
        if [ ! -z "${peerAddrPrefix}" ]; then
            echo "${peerAddrPrefix}${org}.${domain}"
        fi
    else
        echo "${service}${orgComponent}.${domain}"
    fi
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
    local container=$(containerNameString "org" ${service} ${org} ${domain})
    
    local containerHomeDir
    local parentDir
    local container

    connectOrgMachine "${org}" "${domain}"
    dockerMakeDirInContainer ${container} "${destinationPath}"
    containerHomeDir=$(echo $(docker container exec -it ${container} pwd) | tr -d '\r')'/'
    parentDir=$(if [[ ${destinationPath} != /* ]]; then echo ${containerHomeDir}; fi)
    printDbg "docker cp ${sourcePath} ${container}:${parentDir}${destinationPath}"
    docker cp ${sourcePath} ${container}:"${parentDir}${destinationPath}"
    docker container exec -it ${container} ls -la "${parentDir}${destinationPath}" >/dev/null
    setExitCode [[ $? == 0 ]]
}

function dockerCopyFileFromContainer() {
            local service="${1}"
            local org=${2}
            local domain=${3}
            local sourcePath="${4:?Source path is required}"
            local destinationPath="${5:?Destination path is required}"
            local container=$(containerNameString "org" ${service} ${org} ${domain})
            local containerHomeDir
            local parentDir
            local container

            connectOrgMachine "${org}" "${domain}"
            containerHomeDir=$(echo $(docker container exec -it ${container} pwd) | tr -d '\r')'/'
            parentDir=$(if [[ ${destinationPath} != /* ]]; then echo ${containerHomeDir}; fi)
            printDbg "docker cp ${container}:"${parentDir}${sourcePath}" ${destinationPath}"
            docker cp ${container}:"${parentDir}${sourcePath}" ${destinationPath}

            ls -la ${destinationPath} >/dev/null
            setExitCode [[ $? == 0 ]]
}

main $@
