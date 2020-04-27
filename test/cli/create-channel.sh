#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

printToLogAndToScreenCyan "\nCreating the [$channelName] channel for ${org}.${DOMAIN}"

setCurrentActiveOrg ${org}

runInFabricDir ./channel-create.sh ${channelName}
printResultAndSetExitCode "Channel [${channelName}] creation request completed sucsessfuly"