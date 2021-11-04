#!/usr/bin/env bash
BASEDIR=$(dirname "$0")

source lib/container-lib.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/lib/container-lib.sh

${BASEDIR}/wait-for-ip-port.sh ${PEER_NAME}-${ORG}.${DOMAIN} ${PEER0_PORT}
tree /etc/hyperledger/crypto-config/peerOrganizations/

echo -e "\n\nInstall DNS chaincode\n\n"

installChaincode dns ${VERSIONED_CHAINCODE_PATH}/node/dns node 1.0

${BASEDIR}/init-in-open-net.sh