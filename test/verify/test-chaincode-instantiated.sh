#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincode_init_name=${CHAINCODE_PREFIX:-reference}
chaincodeName=${3:-${chaincode_init_name}_${channelName}}

function findChaincodeInQueryCommitedList() {
  local channelName=${1}
  local org=${2}
  local chaincodeName=${3}

  local result=$(runCLIPeer ${org} listChaincodesInstantiated ${channelName} ${org} \| grep -E "^$chaincodeName")
  echo $result

  setExitCode [ ! -z "${result}" ]
}

printToLogAndToScreenBlue "\nVerifing if the test chaincode instantiated in channel [${channelName}] channel by [${org}]"

setCurrentActiveOrg ${org}
result=$(findChaincodeInQueryCommitedList ${channelName} ${org} $chaincodeName)
printResultAndSetExitCode "The test chaincode instantiated in [${channelName}] channel by [${org}] org"
