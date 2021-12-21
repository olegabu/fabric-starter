#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
orgAdd=${3:-${org}}

printToLogAndToScreenBlue "\nVerifing if the [${orgAdd}] added to [${channelName}]"

setCurrentActiveOrg ${org}
result=$(runCLIPeer ${org} findOrgNameInChannelConfig ${channelName} ${orgAdd})

printResultAndSetExitCode "Organization [${orgAdd}] is in the channel [$channelName]"
