#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


channelName=${1}
org=${2}


printToLogAndToScreenBlue "\nVerifing if the [${org}] has joined the [${channelName}] channel..."

setCurrentActiveOrg ${org}

verifyOrgJoinedChannel "${channelName}" "${org}" "${DOMAIN}"

printResultAndSetExitCode "The [${org}] has joined the [${channelName}] channel"
