#!/usr/bin/env bash
source ./container-lib.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/container-lib.sh

echo -e "\n\nInit Open Net. Add myself to Consortium \n\n"

env|sort

downloadOrdererMSP
updateConsortium ${ORG} orderer-system-channel
sleep 3

echo -e "\n\nTrying to create channel common\n\n"

createChannel common
createResult=$?
[ $createResult -eq 0 ] && echo -e "\n\nChannel common created\n\n" || echo -e "\n\nChannel common has already existed\n\n"


#if [ $createResult -ne 0 ]; then
#    sleep 3
#    CHANNEL_OWNER_IP=${CHANNEL_OWNER_IP:-$BOOTSTRAP_IP}
#
#    echo -e "\n\nTrying to add myself into channel by API on http://${CHANNEL_OWNER_IP}:4000 \n\n"
#    set -x
#    if [[ -n "$ORG_IP" || -n "$MY_IP" ]]; then # ORG_IP is deprecated
#        JWT=`(curl -d '{"username":"user${ORG}","password":"pass${ORG}"}' -H "Content-Type: application/json" http://${CHANNEL_OWNER_IP}:4000/users | tr -d '"')`
#        curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" http://${CHANNEL_OWNER_IP}:4000/channels/common/chaincodes/dns -d "{\"fcn\":\"registerOrg\",\"args\":[\"${ORG}.${DOMAIN}\",\"${ORG_IP}${MY_IP}\"],\"waitForTransactionEvent\":true}"
#        sleep 3
#        curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" http://${CHANNEL_OWNER_IP}:4000/channels/common/orgs -d "{\"orgId\":\"${ORG}\"}"
#    fi
#    set +x
#fi

sleep 3
echo -e "\n\nJoining channel 'common'\n\n"
joinChannel common

if [ $createResult -eq 0 ]; then
    sleep 3
    instantiateChaincode ${DNS_CHANNEL:-common} dns
    sleep 3
    if [ -n "$BOOTSTRAP_IP" ]; then
        echo -e "\n\nRegister BOOTSTRAP_IP: $BOOTSTRAP_IP\n\n"
        invokeChaincode common dns "[\"put\",\"$BOOTSTRAP_IP\",\"www.${DOMAIN} orderer.${DOMAIN}\"]"
    fi
fi

sleep 3
if [[ -n "$ORG_IP" || -n "$MY_IP" ]]; then # ORG_IP is deprecated
    echo -e "\n\nRegister MY_IP: $MY_IP\n\n"
    invokeChaincode common dns "[\"registerOrg\",\"${ORG}.${DOMAIN}\",\"$ORG_IP$MY_IP\"]"
fi