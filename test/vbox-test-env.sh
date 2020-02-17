#!/usr/bin/env zsh
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source ${BASEDIR}/libs.sh

main() {
    export MULTIHOST=true

    local gDomain=$(vbox_guessDomain) 
    local gOrgs=$(vbox_guessOrgs)

    if [ $# -lt 2 ]; then
    printUsage " vbox-test-env <DOMAIN> <ORG1> [<ORG2>] [<ORG3>]..." " source ./vbox-test-env.sh ${gDomain} ${gOrgs}"
    return 1
    fi

    printCyan "Local domain '${gDomain}' and '${gOrgs}' orgs found"



    
    source ${BASEDIR}/common-test-env.sh $@
    export -f setCurrentActiveOrg
    export -f resetCurrentActiveOrg
    export -f getOrgIp
    export -f getOrgContainerPort
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
