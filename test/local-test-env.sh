#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh



main() {

    local gDomain=$(guessDomain) 
    local gOrgs=$(guessOrgs)
#channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
    if [ $# -lt 2 ]; then
    printUsage " local-test-env <DOMAIN> <ORG1> [<ORG2>] [<ORG3>]..." " source ./local-test-env.sh ${gDomain} ${gOrgs}"
    return 1
    fi

    printCyan "Local domain '${gDomain}' and '${gOrgs}' orgs found"

    export MULTIHOST=

    export -f setCurrentActiveOrg
    export -f resetCurrentActiveOrg
    export -f getOrgIp
    export -f getOrgContainerPort
    
    source ${BASEDIR}/common-test-env.sh $@
}


function getOrgIp() {
    echo '127.0.0.1'
}

function getOrgContainerPort () {
    getContainerPort $@
}

function setCurrentActiveOrg() {
    local org="${1:?Org name is required}"
    export $ORG=${org}
    export PEER0_PORT=$(getContainerPort ${ORG} ${PEER_NAME} ${DOMAIN})
}

function resetCurrentActiveOrg {
    :
}

main $@
