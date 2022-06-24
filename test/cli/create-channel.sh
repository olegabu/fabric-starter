#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

confFilePath=$(getOrgConfigFilePath ${org} ${NETCONFPATH})
domain=$(getVarFromEnvFile DOMAIN "${confFilePath}")

printToLogAndToScreenCyan "\nCreating the [$channelName] channel for ${org}.${domain}"

export DOMAIN=${domain}
export ORDERER_DOMAIN=$(getOrgOrdererDomain $org)

setCurrentActiveOrg ${org}

runInFabricDir ./channel-create.sh ${channelName}
printResultAndSetExitCode "Channel [${channelName}] creation request completed sucsessfuly"
