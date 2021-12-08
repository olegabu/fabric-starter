#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channel=${1}
org=${2}

printToLogAndToScreenBlue "\nVerifing if the [${channel}] channel exists in [${org}]"

setCurrentActiveOrg ${org}
result=$(peerParseChannelConfig ${channel} ${org} '.data.data[0].payload.header.channel_header' '.channel_id')

setExitCode [ "${result}" = "${channel}" ]
printResultAndSetExitCode "The channel [${channel}] exists and visible to [${org}]"
