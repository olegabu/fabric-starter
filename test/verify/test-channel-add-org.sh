#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channel=${1}
org=${2}
orgAdd=${3:-${org}}

printToLogAndToScreenBlue "\nVerifing if the [${orgAdd}] added to [${channel}]"

setCurrentActiveOrg ${org}
result=$(peerParseChannelConfig ${channel} ${org}  ".data.data[0].payload.data.config.channel_group.groups.Application.groups.${orgAdd}.values.MSP.value" '.config.name')

setExitCode [ "${result}" = "${orgAdd}" ]
printResultAndSetExitCode "Organization [${orgAdd}] is in the channel [$channel]"
