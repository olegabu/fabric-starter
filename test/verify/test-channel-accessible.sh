#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

printToLogAndToScreenBlue "\nVerifing if the [${channelName}] channel exists in [${org}]"

setCurrentActiveOrg ${org}
result=$(runCLIPeer ${org} findChannelNameInConfig ${channelName})

printResultAndSetExitCode "The channel [${channelName}] exists and visible to [${org}]"
