#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

org=${1}
orgInvite=${2}

printToLogAndToScreenCyan  "Add [${orgInvite}] to the default consortium using API" | printToLogAndToScreen
JWT=$(APIAuthorize ${org})


if [ $? -eq 0 ]; then
    #setCurrentActiveOrg ${org}
#    addOrgToChannelAPI ${channelName} ${org} ${JWT} ${orgAdd}
    inviteOrgToDefaultConsortiumAPI ${org} ${orgInvite} ${JWT}
    printResultAndSetExitCode "Organization [${orgInvite}] invited to default consortium by [${org}]"
    #resetCurrentActiveOrg
else
    exit 1
fi
