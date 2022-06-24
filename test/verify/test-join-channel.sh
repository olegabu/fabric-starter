#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

function findChannelInChannelList() {
  local channelName=${1}
  local org=${2}

  local result=$(runCLIPeer ${org} peer channel list -o \$ORDERER_ADDRESS \$ORDERER_TLSCA_CERT_OPTS \| grep -E "^${channelName}$")
  printDbg "Result: $result"

  setExitCode [ ! -z "${result}" ]
}

printToLogAndToScreenBlue "\nVerifing if the [${org}] has joined the [${channelName}] channel..."

setCurrentActiveOrg ${org}
findChannelInChannelList ${channelName} ${org}
printResultAndSetExitCode "The [${org}] org has joined the [${channelName}] channel"
