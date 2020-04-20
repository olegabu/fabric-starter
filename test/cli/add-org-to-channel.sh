#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh
#source "${BASEDIR}"/../libs/parse-common-params.sh $@

channelName=${1}
org=${2}
orgAdd=${3}

printToLogAndToScreenCyan "\nAdd [${orgAdd}] to the [${channelName}] channel"

setCurrentActiveOrg ${org}

runInFabricDir ./channel-add-org.sh ${channelName} ${orgAdd}

printResultAndSetExitCode "Organization [${orgAdd}] added to [${channelName}] channel"