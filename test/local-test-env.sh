#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

main() {
    source ${BASEDIR}/common-test-env.sh $@
}


function getOrgIp() {
    echo '127.0.0.1'
}

function getOrgContainerPort () {
    getContainerPort $@
}

function setCurrentActiveOrg() {
    local org="${1}"
    setActiveOrg "${org}"
}

function resetCurrentActiveOrg {
    resetActiveOrg
}

main $@
