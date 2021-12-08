#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channel=${1}
org=${2}

printToLogAndToScreenBlue "\nVerifing if the [${org}] has joined the [${channel}] channel..."

setCurrentActiveOrg ${org}
result=$(runCLIPeer ${org} peer channel list -o \$ORDERER_ADDRESS \$ORDERER_TLSCA_CERT_OPTS \| grep -E "^${channel}$")

setExitCode [ "${result}" = "${channel}" ]
printResultAndSetExitCode "The [${org}] org has joined the [${channel}] channel"
