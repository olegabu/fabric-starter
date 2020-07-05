#!/usr/bin/env bash
BASEDIR=$(dirname "$0")

source lib/container-lib.sh 2>/dev/null # for IDE code completion
source lib/container-util.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/lib/container-lib.sh
source $(dirname "$0")/lib/container-util.sh

echo -e "\n\nInit Open Net. Add myself to Consortium \n\n"

: ${ORDERER_DOMAIN:=${ORDERER_DOMAIN:-${DOMAIN}}}
: ${ORDERER_NAME:=${ORDERER_NAME:-orderer}}
: ${ORDERER_WWW_PORT:=${ORDERER_WWW_PORT:-80}}

: ${SERVICE_CC_NAME:=dns}
: ${CONSORTIUM_AUTO_APPLY:=${CONSORTIUM_AUTO_APPLY-SampleConsortium}}
: ${CHANNEL_AUTO_JOIN:=${CHANNEL_AUTO_JOIN-${DNS_CHANNEL}}} # no auto-join if specifically set to empty or ""
DNS_CHANNEL=${DNS_CHANNEL-common}

export ORDERER_DOMAIN ORDERER_NAME ORDERER_WWW_PORT

function main() {
    env|sort

    downloadOrdererMSP ${ORDERER_NAME} ${ORDERER_DOMAIN} ${ORDERER_WWW_PORT}
    addMeToConsortiumIfOrdererExists
    if [[ ! ${DNS_CHANNEL} ]]; then
        printYellow "\nDNS_CHANNEL is set to empty. Skipping joining."
        exit
    fi
    createServiceChannel ${DNS_CHANNEL}
    createResult=$?
    requestInviteToServiceChannel ${createResult} ${DNS_CHANNEL}
    sleep 3
    joinServiceChannel ${DNS_CHANNEL}
    joinResult=$?

    sleep 3
    if [[ $createResult -eq 0 && -n "$BOOTSTRAP_IP" ]]; then
        instantiateChaincode ${DNS_CHANNEL} ${SERVICE_CC_NAME}
        registerOrdererInServiceChaincode ${DNS_CHANNEL} ${SERVICE_CC_NAME}
    fi

    if [[ $joinResult -eq 0 && -n "$BOOTSTRAP_IP" ]]; then
        registerOrgInServiceChaincode ${DNS_CHANNEL} ${SERVICE_CC_NAME}
    fi
}

function addMeToConsortiumIfOrdererExists() {
    echo "Check orderer cert ${ORDERER_GENERAL_TLS_ROOTCERT_FILE} in order to apply to consortium"
    if [ -f "${ORDERER_GENERAL_TLS_ROOTCERT_FILE}" ]; then
        echo "File  ${ORDERER_GENERAL_TLS_ROOTCERT_FILE} exists. Auto apply to consortium: ${CONSORTIUM_AUTO_APPLY}"

        status=1
        while [[ ${status} -ne 0 && ${CONSORTIUM_AUTO_APPLY} && ( -z "$BOOTSTRAP_IP" || ( "$BOOTSTRAP_IP" == "$MY_IP" )) ]]; do
            printYellow "\n\nTrying to add  ${ORG} to consortium\n\n"
            runAsOrderer ${BASEDIR}/orderer/consortium-add-org.sh ${ORG} ${DOMAIN}
            sleep $(( RANDOM % 20 )) #TODO: make external locking for config updates
            runAsOrderer ${BASEDIR}/orderer/consortium-add-org.sh ${ORG} ${DOMAIN}
            status=$?
            echo -e "Status: $status\n"
            sleep 3
        done
    fi
}

function createServiceChannel() {
    local serviceChannel=${1:?Service channel name is required}
    printYellow "\nTrying to create channel ${serviceChannel}\n"
    createChannel ${serviceChannel}
    createResult=$?
    sleep 3
    [[ $createResult -eq 0 ]] && printGreen "\nChannel 'common' has been created\n" || printYellow "\nChannel '${serviceChannel}' cannot be created or already exists\n"
    return ${createResult}
}

function requestInviteToServiceChannel() {
    local creationResult=${1:?Channel Creation result is required}
    local serviceChannel=${2:?Service channel name is required}

    if [[ $creationResult -ne 0 &&  -n "${BOOTSTRAP_IP}" ]]; then
       printYellow "\nRequesting invitation to channel ${serviceChannel}, $BOOTSTRAP_SERVICE_URL \n"
       set -x
       curl -k ${BOOTSTRAP_SERVICE_URL:-https}://${BOOTSTRAP_IP}:${BOOTSTRAP_API_PORT}/integration/service/orgs -H 'Content-Type: application/json' -d "{\"orgId\":\"${ORG}\",\"orgIp\":\"${MY_IP}\",\"peerPort\":\"${PEER0_PORT}\",\"wwwPort\":\"${WWW_PORT}\"}"
       set +x
    fi
}

function joinServiceChannel() {
    local serviceChannel=${1:?Service channel name is required}
    printYellow "\n\nJoining channel '${serviceChannel}'\n\n"
    status=1
    while [[ ${status} -ne 0 ]]; do
        joinOutput=`joinChannel ${serviceChannel} 2>&1`
        status=$?
        echo -e "${joinOutput}\nStatus: $status\n"
        if [[ "${joinOutput}" =~ "LedgerID already exists" ]];then
            status=0
        fi
        sleep 4
    done

    joinResult=$?
    printGreen "\nJoined channel '${serviceChannel}'\n"
    return ${joinResult}
}

function registerOrdererInServiceChaincode() {
    local serviceChannel=${1:?Service channel name is required}
    local serviceChaincode=${2:?Service chaincode is required}

    sleep 5
    if [ -n "$BOOTSTRAP_IP" ]; then
        printYellow "\nRegister BOOTSTRAP_IP: $BOOTSTRAP_IP\n"
        invokeChaincode ${serviceChannel} ${SERVICE_CC_NAME} "[\"registerOrderer\",\"${ORDERER_NAME}\", \"${ORDERER_DOMAIN}\", \"${ORDERER_GENERAL_LISTENPORT}\", \"$BOOTSTRAP_IP\"]"
    fi
}

function registerOrgInServiceChaincode() {
    local serviceChannel=${1:?Service channel name is required}
    local serviceChaincode=${2:?Service chaincode is required}

    sleep 5
    if [[ -n "$MY_IP" || -n "$ORG_IP" ]]; then # ORG_IP is deprecated
        printYellow "\nRegister MY_IP: $MY_IP\n"
        invokeChaincode ${serviceChannel} ${serviceChaincode} "[\"registerOrg\",\"${ORG}.${DOMAIN}\",\"$ORG_IP$MY_IP\"]"
    fi
}

main