#!/usr/bin/env bash
BASEDIR=$(dirname "$0")

source lib/container-lib.sh 2>/dev/null # for IDE code completion
source lib/container-util.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/lib/container-lib.sh
source $(dirname "$0")/lib/container-util.sh

echo -e "\n\nInit Open Net. Add myself to Consortium \n\n"

: ${ORDERER_DOMAIN:=${ORDERER_DOMAIN:-${DOMAIN}}}
: ${ORDERER_NAME:=${ORDERER_NAME:-orderer}}
: ${WWW_PORT:=${WWW_PORT:-80}}
: ${ORDERER_WWW_PORT:=${ORDERER_WWW_PORT:-80}}
: ${ORDERER_NAMES:=${ORDERER_NAMES:-${ORDERER_NAME}}}
: ${BOOTSTRAP_EXTERNAL_PORT:=${BOOTSTRAP_EXTERNAL_PORT:-${API_PORT}}}

: ${SERVICE_CC_NAME:=dns}
: ${CONSORTIUM_AUTO_APPLY:=${CONSORTIUM_AUTO_APPLY-SampleConsortium}}

#DNS_CHANNEL=${DNS_CHANNEL-common}
: ${DNS_CHANNEL:=${DNS_CHANNEL-common}} # no auto-join if specifically set to empty or ""
: ${CHANNEL_AUTO_JOIN:=${CHANNEL_AUTO_JOIN-${DNS_CHANNEL}}} # no auto-join if specifically set to empty or ""

export ORDERER_DOMAIN ORDERER_NAME ORDERER_NAMES ORDERER_WWW_PORT

env|sort

function main() {
#    addMeToConsortiumIfOrdererExists
    if [[ ! ${CHANNEL_AUTO_JOIN} ]]; then
        printYellow "\nCHANNEL_AUTO_JOIN is set to empty. Skipping joining."
        exit
    fi
    env|sort
    downloadOrdererMSP ${ORDERER_NAME} ${ORDERER_DOMAIN} #${ORDERER_WWW_PORT}
    createServiceChannel ${DNS_CHANNEL}
    createResult=$?
    requestInviteToServiceChannel ${createResult} ${DNS_CHANNEL} #todo
    sleep 3
    joinServiceChannel ${DNS_CHANNEL}
    joinResult=$?

    sleep 3
    if [[ $createResult -eq 0 ]]; then
        instantiateChaincode ${DNS_CHANNEL} ${SERVICE_CC_NAME}
        registerOrdererInServiceChaincode ${DNS_CHANNEL} ${SERVICE_CC_NAME}
    else
        approveChaincode ${DNS_CHANNEL} ${SERVICE_CC_NAME}
    fi

    if [[ $joinResult -eq 0 ]]; then
        registerOrgInServiceChaincode ${DNS_CHANNEL} ${SERVICE_CC_NAME}
    fi
}

function addMeToConsortiumIfOrdererExists() {
    echo "Check orderer cert ${ORDERER_GENERAL_TLS_ROOTCERT_FILE} in order to apply to consortium"
    if [ -f "${ORDERER_GENERAL_TLS_ROOTCERT_FILE}" ]; then
        echo "File  ${ORDERER_GENERAL_TLS_ROOTCERT_FILE} exists. Auto apply to consortium: ${CONSORTIUM_AUTO_APPLY}"

        local count=0
        local status=1
        while [[ ${count} -lt 3 && ${status} -ne 0 && ${CONSORTIUM_AUTO_APPLY} && ( -z "$BOOTSTRAP_IP" || ( "$BOOTSTRAP_IP" == "$MY_IP" )) ]]; do
            printYellow "\n\nTrying to add  ${ORG} to consortium\n\n"
            runAsOrderer ${BASEDIR}/orderer/consortium-add-org.sh ${ORG} ${WWW_PORT} ${DOMAIN}
            sleep $(( RANDOM % 20 )) #TODO: make external locking for config updates
            runAsOrderer ${BASEDIR}/orderer/consortium-add-org.sh ${ORG} ${WWW_PORT} ${DOMAIN}
            status=$?
            echo -e "Status: $status\n, Count: $count"
            count=$((count+1))
            sleep 3
        done
    fi
}

function createServiceChannel() {
    local serviceChannel=${1:?Service channel name is required}
    if [ -z "$BOOTSTRAP_IP" ]; then
        printYellow "\nTrying to create channel ${serviceChannel}\n"
        createChannel ${serviceChannel}
        createResult=$?
        sleep 3
        [[ $createResult -eq 0 ]] && printGreen "\nChannel 'common' has been created\n" || printYellow "\nChannel '${serviceChannel}' cannot be created or already exists\n"
        return ${createResult}
    fi
}

function requestInviteToServiceChannel() {
    local creationResult=${1:?Channel Creation result is required}
    local serviceChannel=${2:?Service channel name is required}

    ${BASEDIR}/wait-port.sh ${ORDERER_NAME}.${DOMAIN} ${ORDERER_GENERAL_LISTENPORT}
    set -x
    sleep ${ORDERER_STARTING_PERIOD:-30} # TODO: orderer may have open port but not be operating yet
    set +x

    if [[ -n "$BOOTSTRAP_IP" && ${CHANNEL_AUTO_JOIN} ]]; then
       printYellow "\nRequesting invitation to channel ${serviceChannel}, $BOOTSTRAP_SERVICE_URL \n"
       set -x
       curl -i --connect-timeout 30 --max-time 120 --retry 1 -k ${BOOTSTRAP_SERVICE_URL:-https}://${MASTER_IP:-${BOOTSTRAP_IP:-api.${BOOTSTRAP_ORG_DOMAIN}}:${BOOTSTRAP_EXTERNAL_PORT}}/integration/service/orgs \
            -H 'Content-Type: application/json' -d "{\"orgId\":\"${ORG}\",\"domain\":\"${DOMAIN}\",\"orgIp\":\"${MY_IP}\",\"peerPort\":\"${PEER0_PORT}\",\"wwwPort\":\"${WWW_PORT}\",\"peerName\":\"${PEER_NAME}\"}"
       local curlResult=$?
       set +x
       echo "Curl result: $curlResult"
#    else #TODO: should'n go here if no AUTO_JOIN
#        if [[ -n "$BOOTSTRAP_IP" ]]; then
#            set -x
#            curl -i --connect-timeout 30 --max-time 120 --retry 1 -k ${BOOTSTRAP_SERVICE_URL:-https}://${MASTER_IP:-${BOOTSTRAP_IP:-api.${BOOTSTRAP_ORG_DOMAIN}}:${BOOTSTRAP_EXTERNAL_PORT}}/integration/dns/org \
#                 -H 'Content-Type: application/json' -d "{\"orgId\":\"${ORG}\",\"domain\":\"${DOMAIN}\",\"orgIp\":\"${MY_IP}\",\"peerPort\":\"${PEER0_PORT}\",\"wwwPort\":\"${WWW_PORT}\",\"peerName\":\"${PEER_NAME}\",\"peerName\":\"${PEER_NAME}\"}"
#            local curlResult=$?
#            set +x
#            echo "Curl result: $curlResult"
#        fi
    fi
}

function joinServiceChannel() {
    local serviceChannel=${1:?Service channel name is required}
    local joinResult=1
    if [[ ${CHANNEL_AUTO_JOIN} ]]; then
        status=1
        count=1
        while [[ ${status} -ne 0 && ${count} -le 3 ]]; do
            printYellow "\n\nJoining channel '${serviceChannel}, try ${count} '\n\n"
            joinOutput=`joinChannel ${serviceChannel} 2>&1`
            status=$?
            echo -e "${joinOutput}\nStatus: $status\n"
            if [[ "${joinOutput}" =~ "LedgerID already exists" ]];then
                status=0
            fi

            [[ ${status} -ne 0 ]] && sleep 10
            count=$((count + 1))
        done

        joinResult=$status
        if [[ joinResult -eq 0 ]]; then
           printGreen "\nJoined channel '${serviceChannel}'\n"
           sleep 5
        else
           printError "\nNot joined to '${serviceChannel}'\n"
        fi
    fi
    return ${joinResult}
}

function registerOrdererInServiceChaincode() {
    local serviceChannel=${1:?Service channel name is required}
    local serviceChaincode=${2:?Service chaincode is required}

    sleep 5
    if [[ -z "$BOOTSTRAP_IP" && -n "$MY_IP" ]]; then # TODO:

        local ordererNames
        IFS="," read -r -a ordererNames <<< ${ORDERER_NAMES}
        for ordererName_Port in ${ordererNames[@]}; do
          local ordererConf
          IFS=':' read -r -a ordererConf <<< ${ordererName_Port}
          local ordererName=${ordererConf[0]}
          local ordererPort=${ordererConf[1]:-${ORDERER_GENERAL_LISTENPORT}}
          printYellow "\nRegister ORDERER: ${ordererName}.${ORDERER_DOMAIN}:"$MY_IP"\n"
          invokeChaincode ${serviceChannel} ${SERVICE_CC_NAME} "[\"registerOrdererByParams\",\"${ordererName}\", \"${ORDERER_DOMAIN}\", \"${ordererPort}\", \"${MY_IP}\", \"${ORDERER_WWW_PORT}\"]"
          sleep 5
        done
    fi
}

function registerOrgInServiceChaincode() {
    local serviceChannel=${1:?Service channel name is required}
    local serviceChaincode=${2:?Service chaincode is required}

    sleep 5
    if [[ -n "$MY_IP" || -n "$ORG_IP" ]]; then # ORG_IP is deprecated
        printYellow "\nRegister MY_IP: $MY_IP\n"
        cat /etc/hosts
        invokeChaincode ${serviceChannel} ${serviceChaincode} "[\"registerOrgByParams\",\"${ORG}\", \"${DOMAIN}\",\"$ORG_IP$MY_IP\", \"${PEER0_PORT}\", \"${WWW_PORT}\", \"${PEER_NAME}\"]"
    fi
}

main