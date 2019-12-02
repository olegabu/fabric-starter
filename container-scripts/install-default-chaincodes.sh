#!/usr/bin/env bash
BASEDIR=$(dirname "$0")

source lib/container-lib.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/lib/container-lib.sh

echo -e "\n\nInstall DNS chaincode\n\n"
installChaincode dns /opt/chaincode/node/dns node 1.0

export ORDERER_NAME_PREFIX
${BASEDIR}/init-in-open-net.sh