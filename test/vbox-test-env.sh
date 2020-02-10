#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source ${BASEDIR}/libs.sh

main() {
    export MULTIHOST=true
    
    source ${BASEDIR}/common-test-env.sh $@
    export -f setCurrentActiveOrg
    export -f resetCurrentActiveOrg
    
}

function setCurrentActiveOrg() {
    local org="${1:?Org name is required}"
    connectMachine ${org} 1>&2
    export $ORG=$org
}

function resetCurrentActiveOrg {
    eval $(docker-machine env -u) >/dev/null
}


function getOrgIp() {
    getMachineIp "${1}"
}

function getOrgContainerPort () {
    local org="${1:?Org name is required}"
    setCurrentActiveOrg "${org}"
    getContainerPort $@
    resetCurrentActiveOrg
}

main $@
