#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channel=${1}
org=${2}
chaincode_init_name=${CHAINCODE_PREFIX:-reference}
chaincode_name=${3:-"${chaincode_init_name}_${channel}"}
lang=${4:-node}
path=${5:-"${VERSIONED_CHAINCODE_PATH}/${lang}/reference"}

printDbg $(printArgs $@)

printToLogAndToScreenCyan "\nInstalling test chaincode in [${org}]"

setCurrentActiveOrg ${org}

printToLogAndToScreenCyan "\nCopying test chaincode to [${org}]"

result1=$(runCLIPeer ${org} \
  "mkdir -p ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincode_name};  \
          cp -R ${path}/* \
          ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincode_name}")
exitCode1=$?

printToLogAndToScreenCyan "\nInstalling [$(getTestChaincodeName ${channel})] chaincode in [${org}]"

result2=$(runCLIPeer ${org} \
  "./container-scripts/network/chaincode-install.sh '${chaincode_name}' 1.0 ${VERSIONED_CHAINCODE_PATH}/${lang}/${chaincode_name} ${lang}" 2>&1)
exitCode2=$?

exitCode=$((exitCode1||exitCode2))

set +f
IFS=
  printDbg "Copy result: ${result1}"
  printDbg "Install result: ${result2}"
set -f
setExitCode [ "${exitCode}" = "0" ]

printResultAndSetExitCode "Test chaincode installed in [${org}]"
