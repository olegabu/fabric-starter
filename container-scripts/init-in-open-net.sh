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

: ${DNS_CHANNEL:=common}
: ${CONSORTIUM_AUTO_APPLY:=${CONSORTIUM_AUTO_APPLY-SampleConsortium}}
: ${CHANNEL_AUTO_JOIN:=${CHANNEL_AUTO_JOIN-$DNS_CHANNEL}} # no auto-join if specifically set to empty or ""

export ORDERER_DOMAIN ORDERER_NAME ORDERER_WWW_PORT

env|sort

downloadOrdererMSP ${ORDERER_NAME} ${ORDERER_DOMAIN} ${ORDERER_WWW_PORT}

setOrdererIdentity ${ORDERER_NAME} ${ORDERER_DOMAIN} /etc/hyperledger/crypto-config
if [ -f "${CORE_PEER_TLS_ROOTCERT_FILE}" ]; then
#    printError "No file ${CORE_PEER_TLS_ROOTCERT_FILE}. Exiting."
    echo "File  ${CORE_PEER_TLS_ROOTCERT_FILE} exists."

    ORG_CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}
    ORG_CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}
    ORG_CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}

    status=1
    while [[ ${status} -ne 0 && $CONSORTIUM_AUTO_APPLY ]]; do
        printYellow "\n\nTrying to add  ${ORG} to consortium\n\n"
        ${BASEDIR}/orderer/consortium-add-org.sh ${ORG} ${DOMAIN}
        sleep $(( RANDOM % 10 ))
        ${BASEDIR}/orderer/consortium-add-org.sh ${ORG} ${DOMAIN}
        status=$?
        sleep 3
    done

    CORE_PEER_LOCALMSPID=${ORG_CORE_PEER_LOCALMSPID}
    CORE_PEER_MSPCONFIGPATH=${ORG_CORE_PEER_MSPCONFIGPATH}
    CORE_PEER_TLS_ROOTCERT_FILE=${ORG_CORE_PEER_TLS_ROOTCERT_FILE}

    printYellow "\nTrying to create channel common\n"

    createChannel ${DNS_CHANNEL}
    createResult=$?
    sleep 3
    if [ $createResult -eq 0 ]; then
        printGreen "\n\nChannel 'common' has been created\n\n"
    else
        printYellow "\n\nChannel 'common' already exists\n\n"
    fi
fi

CORE_PEER_LOCALMSPID=${ORG_CORE_PEER_LOCALMSPID}
CORE_PEER_MSPCONFIGPATH=${ORG_CORE_PEER_MSPCONFIGPATH}
CORE_PEER_TLS_ROOTCERT_FILE=${ORG_CORE_PEER_TLS_ROOTCERT_FILE}

printYellow "\n\nJoining channel '${CHANNEL_AUTO_JOIN}'\n\n"
status=1
while [[ ${status} -ne 0 && ${CHANNEL_AUTO_JOIN} ]]; do
    joinChannel ${CHANNEL_AUTO_JOIN}
    status=$?
    echo -e "Status: $status\n"
    sleep 5
done

printGreen "\n\nJoined channel '${CHANNEL_AUTO_JOIN}'\n\n"

joinResult=$?

if [ $createResult -eq 0 ]; then
    sleep 3
    instantiateChaincode ${DNS_CHANNEL} dns
    sleep 15
    if [ -n "$BOOTSTRAP_IP" ]; then
        printYellow "\nRegister BOOTSTRAP_IP: $BOOTSTRAP_IP\n"
        invokeChaincode ${DNS_CHANNEL:-common} dns "[\"registerOrderer\",\"${ORDERER_NAME}\", \"${ORDERER_DOMAIN}\", \"${ORDERER_GENERAL_LISTENPORT}\", \"$BOOTSTRAP_IP\"]"
    fi
fi

if [[ $joinResult -eq 0 && -n "$BOOTSTRAP_IP" ]]; then
    sleep 3
    if [[ -n "$ORG_IP" || -n "$MY_IP" ]]; then # ORG_IP is deprecated
        printYellow "\nRegister MY_IP: $MY_IP\n"
        invokeChaincode ${DNS_CHANNEL} dns "[\"registerOrg\",\"${ORG}.${DOMAIN}\",\"$ORG_IP$MY_IP\"]"
    fi
fi