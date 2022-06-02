#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincodeName=${3:-$(getTestChaincodeName ${channelName})}

function findChaincodeInQueryInstalledList() {
  local channelName=${1}
  local org=${2}
  local chaincodeName=${3}
  
  local result=$(runCLIPeer ${org} listChaincodesInstalled ${channelName} ${org} \| grep -E "^${chaincodeName}$")
  echo $result

  setExitCode [ ! -z "${result}" ]
}
  
printToLogAndToScreenBlue "\nVerifing if the chaincode [${chaincodeName}] installed in [${org}]"

setCurrentActiveOrg ${org}
result=$(findChaincodeInQueryInstalledList ${channelName} ${org} ${chaincodeName})
printResultAndSetExitCode "The test chaincode installed in [${org}]"
