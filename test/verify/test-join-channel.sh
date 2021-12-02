#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


channelName=${1}
org=${2}
domain=${3:-${DOMAIN}}


printToLogAndToScreenBlue "\nVerifing if the [${org}] has joined the [${channelName}] channel..."

setCurrentActiveOrg ${org}
verifyOrgJoinedChannel "${channelName}" "${org}" "${domain}"

printResultAndSetExitCode "The [${org}.${domain}] org has joined the [${channelName}] channel"
