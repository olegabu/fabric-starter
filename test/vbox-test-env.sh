#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
#echo " $0 _____ ${BASH_SOURCE[0]} ____ $BASEDIR"
#BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${BASEDIR}/libs.sh

main() {
    export MULTIHOST=true
    
    source ${BASEDIR}/common-test-env.sh $@
}

function setCurrentActiveOrg() {
    local org="${1}"
    connectMachine ${org} 1>&2
    setActiveOrg "${org}"
}

function resetCurrentActiveOrg {
    resetActiveOrg
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