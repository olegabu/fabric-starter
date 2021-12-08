#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channel=${1}
org=${2}
chaincode_init_name=${CHAINCODE_PREFIX:-reference}
chaincode_name=${3:-"${chaincode_init_name}_${channel}"}
lang=${4:-node}
path=${5:-"${BASEDIR}/../resources/chaincode/${FABRIC_MAJOR_VERSION}x/${lang}/reference/."}

printToLogAndToScreenCyan "\nInstalling test chaincode in [${org}]"
setCurrentActiveOrg ${org}

printToLogAndToScreenCyan "\nCopying test chaincode to [${org}]"
copyDirToContainer cli.peer0  ${org} ${DOMAIN:-example.com} "${path}" "${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincode_name}"

printToLogAndToScreenCyan "\nInstalling [$(getTestChaincodeName ${channel})] chaincode in [${org}]"
result=$(runCLIPeer ${org} \
  "./container-scripts/network/chaincode-install.sh '${chaincode_name}' 1.0 ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincode_name} ${lang}")

printResultAndSetExitCode "Test chaincode installed in [${org}]"
