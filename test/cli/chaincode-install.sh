#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

chaincodeInitName=${CHAINCODE_PREFIX:-reference}
chaincodeName=${3:-"$(getTestChaincodeName ${channelName})"}
version=${4:-'1.0'}
lang=${5:-node}
path=${6:-"${BASEDIR}/../resources/chaincode/${FABRIC_MAJOR_VERSION}x/${lang}/${chaincodeInitName}/."}

printToLogAndToScreenCyan "\nInstalling chaincode in [${org}] from $path"
setCurrentActiveOrg ${org}

peerName=$(getPeerName ${org})

printToLogAndToScreenCyan "\nCopying test chaincode to [${org}]"
copyDirToContainer cli.${peerName} ${org} ${DOMAIN:-example.com} "${path}" "${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincodeName}"

printToLogAndToScreenCyan "\nInstalling [${chaincodeName}] chaincode in [${org}]"
result=$(runCLIPeer ${org} \
  "./container-scripts/network/chaincode-install.sh '${chaincodeName}' 1.0 ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincodeName} ${lang}")

printResultAndSetExitCode "Test chaincode installed in [${org}]"
