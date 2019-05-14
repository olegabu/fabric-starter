#!/usr/bin/env bash
source ./container-lib.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/container-lib.sh

echo -e "\n\nInit Open Net\n\n"

env|sort

downloadOrdererMSP
updateConsortium ${ORG} orderer-system-channel
sleep 3

echo -e "\n\nTrying to create channel common\n\n"

createChannel common
createResult=$?
[ $createResult -eq 0 ] && echo -e "\n\nChannel common created\n\n" || echo -e "\n\nChannel common already existed\n\n"
sleep 3
echo -e "\n\nJoining channel 'common'\n\n"
joinChannel common

if [ $createResult -eq 0 ]; then
    sleep 3
    instantiateChaincode ${DNS_CHANNEL:-common} dns
    sleep 3
    if [ -n "$BOOTSTRAP_IP" ]; then
        echo -e "\n\nRegister BOOTSTRAP_IP\n\n"
        invokeChaincode common dns "[\"put\",\"$BOOTSTRAP_IP\",\"www.${DOMAIN} orderer.${DOMAIN}\"]"
    fi
fi

sleep 3
if [ -n "$ORG_IP" ]; then
    echo -e "\n\nRegister ORG_IP\n\n"
    invokeChaincode common dns "[\"put\",\"$ORG_IP\",\"www.${ORG}.${DOMAIN} peer0.${ORG}.${DOMAIN}\"]"
fi
