#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

main() {

    local gDomain=$(guessDomain)
    local gOrgs=$(guessOrgs)

    printCyan "Local domain '${gDomain}' and '${gOrgs}' orgs found"

    export MULTIHOST=
    source ${BASEDIR}/common-test-env.sh $@
    
    export -f setCurrentActiveOrg
    export -f resetCurrentActiveOrg
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
}

function resetCurrentActiveOrg {
    :
}

main $@
