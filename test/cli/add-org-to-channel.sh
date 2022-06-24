#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
orgAdd=${3}

peer0Port=$(getOrgContainerPort ${orgAdd} peer0)
wwwPort=$(getWwwPort ${orgAdd})
orgDomain=$(getOrgDomain ${orgAdd})
wwwInternalPeerPort=$(getContainerTCPReversePortMapping ${wwwPort} www.peer ${orgAdd} ${orgDomain})

printToLogAndToScreenCyan "\nAdd [${orgAdd}] to the [${channelName}] channel"

setCurrentActiveOrg ${org}
runInFabricDir ./channel-add-org.sh ${channelName} ${orgAdd} ${peer0Port} ${wwwInternalPeerPort} ${orgDomain}

printResultAndSetExitCode "Organization [${orgAdd}] added to [${channelName}] channel"
