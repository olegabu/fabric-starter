#!/usr/bin/env bash
source ./container-lib.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/container-lib.sh

echo -e "\n\nInit Open Net\n\n"

env|sort

downloadOrdererMSP
updateConsortium ${ORG} orderer-system-channel
sleep 3

echo -e "\n\nTry to create channel common\n\n"

createChannel common
if [ $? -eq 0 ]; then
    echo -e "\n\nChannel common created\n\n"
    sleep 3
    joinChannel common
    sleep 3
    instantiateChaincode ${DNS_CHANNEL:-common} dns
    sleep 3
    if [ -n "$BOOTSTRAP_IP" ]; then
        echo -e "\n\nRegister BOOTSTRAP_IP\n\n"
        invokeChaincode common dns "[\"put\",\"$BOOTSTRAP_IP\",\"www.${DOMAIN} orderer.${DOMAIN}\"]"
    fi
    sleep 3
    if [ -n "$ORG_IP" ]; then
        echo -e "\n\nRegister ORG_IP\n\n"
        invokeChaincode common dns "[\"put\",\"$ORG_IP\",\"www.${ORG}.${DOMAIN} peer0.${ORG}.${DOMAIN}\"]"
    fi
fi