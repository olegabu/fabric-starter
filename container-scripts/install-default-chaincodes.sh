#!/usr/bin/env bash
source ./container-lib.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/container-lib.sh

env|sort

installChaincode dns /opt/chaincode/node/dns node 1.0

downloadMSP
updateConsortium ${ORG} orderer-system-channel
sleep 2
createChannel common
sleep 2
joinChannel common
#sleep 2
#instantiateChaincode ${DNS_CHANNEL:-common} dns
