#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh

org=${1}
orgInvite=${2}

orgInviteDomain=$(getOrgDomain ${orgInvite})

printToLogAndToScreenCyan "\nInvite [${orgInvite}] to the default consortium..."

setCurrentActiveOrg ${org}
runInFabricDir ./consortium-add-org.sh ${orgInvite} ${orgInviteDomain}

printResultAndSetExitCode "Organization [${orgInvite}] added to the default consortium"
