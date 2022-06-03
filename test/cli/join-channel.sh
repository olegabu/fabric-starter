#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

printToLogAndToScreenCyan "\nJoining [${org}] to the [${channelName}] channel..."

setCurrentActiveOrg ${org}

runInFabricDir ./channel-join.sh ${channelName}

printResultAndSetExitCode "Organization [${org}] joined to [${channelName}] channel"
