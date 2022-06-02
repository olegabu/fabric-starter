#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


channelName=${1}
org=${2}

chaincodeInitName=${CHAINCODE_PREFIX:-reference}
chaincodeName=${3:-$(getTestChaincodeName ${channelName})}
version=${4:-'1.0'}
lang=${5:-node}
path=${6:-"${BASEDIR}/../resources/chaincode/${FABRIC_MAJOR_VERSION}x/${lang}/${chaincodeInitName}/."}


printToLogAndToScreenCyan "\nInstalling test chaincode in [${org}]"

JWT=$(APIAuthorize ${org})

if [ $? -eq 0 ]; then
    installZippedChaincodeAPI ${channelName} ${org} ${JWT} ${chaincodeName} ${version} ${path} ${lang}
    printResultAndSetExitCode "Test chaincode installed in [${org}]"
else
    exit 1
fi