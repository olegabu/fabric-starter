#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=$2
orgAdd=$3

printToLogAndToScreenBlue "\nVerifing if the [${orgAdd}] added to [${channelName}]"

setCurrentActiveOrg ${orgAdd}
verifyOrgIsInChannel "${channelName}" "${orgAdd}" "${DOMAIN}"

printResultAndSetExitCode "Organization [${orgAdd}] is in the channel [$channelName]"
