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

export ORDERER_DOMAIN ORDERER_NAME ORDERER_WWW_PORT

env|sort

downloadOrdererMSP ${ORDERER_NAME} ${ORDERER_DOMAIN} ${ORDERER_WWW_PORT}

ORG_CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}
ORG_CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}
ORG_CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}

setOrdererIdentity ${ORDERER_NAME} ${ORDERER_DOMAIN} /etc/hyperledger/crypto-config
if [ ! -f "${CORE_PEER_TLS_ROOTCERT_FILE}" ]; then
    echo "No file ${CORE_PEER_TLS_ROOTCERT_FILE}. Exiting."
    exit
fi
echo "File  ${CORE_PEER_TLS_ROOTCERT_FILE} exists."


echo -e "\n\nTrying to add  ${ORG} to consortium\n\n"
${BASEDIR}/orderer/consortium-add-org.sh ${ORG} ${DOMAIN}

CORE_PEER_LOCALMSPID=${ORG_CORE_PEER_LOCALMSPID}
CORE_PEER_MSPCONFIGPATH=${ORG_CORE_PEER_MSPCONFIGPATH}
CORE_PEER_TLS_ROOTCERT_FILE=${ORG_CORE_PEER_TLS_ROOTCERT_FILE}

echo -e "\n\nTrying to create channel common\n\n"

createChannel common
createResult=$?
[ $createResult -eq 0 ] && echo -e "\n\nChannel 'common' has been created\n\n" || echo -e "\n\nChannel 'common' already exists\n\n"

sleep 3
echo -e "\n\nJoining channel 'common'\n\n"
joinChannel common
joinResult=$?

if [ $createResult -eq 0 ]; then
    sleep 3
    instantiateChaincode ${DNS_CHANNEL:-common} dns
    sleep 15
    if [ -n "$BOOTSTRAP_IP" ]; then
        echo -e "\n\nRegister BOOTSTRAP_IP: $BOOTSTRAP_IP\n\n"
        invokeChaincode ${DNS_CHANNEL:-common} dns "[\"registerOrderer\",\"${ORDERER_NAME}\", \"${ORDERER_DOMAIN}\", \"${ORDERER_GENERAL_LISTENPORT}\", \"$BOOTSTRAP_IP\"]"
    fi
fi

invokeChaincode ${DNS_CHANNEL:-common} dns "[\"registerOrg\",\"${ORG}.${DOMAIN}\",\"$ORG_IP$MY_IP\"]"

if [[ $joinResult -eq 0 && -n "$BOOTSTRAP_IP" ]]; then
    sleep 3
    if [[ -n "$ORG_IP" || -n "$MY_IP" ]]; then # ORG_IP is deprecated
        echo -e "\n\nRegister MY_IP: $MY_IP\n\n"
        invokeChaincode ${DNS_CHANNEL:-common} dns "[\"registerOrg\",\"${ORG}.${DOMAIN}\",\"$ORG_IP$MY_IP\"]"
    fi
fi