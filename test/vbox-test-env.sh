#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source ${BASEDIR}/libs/libs.sh

main() {
    export MULTIHOST=true
    VBOX_HOST_IP=${VBOX_HOST_IP:-$(VBoxManage list hostonlyifs | grep 'IPAddress' | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')}
    setDocker_LocalRegistryEnv
    export DEPLOYMENT_TARGET='vbox'
    export NETCONFPATH="$(absDirPath "${1}")"

    
    if [ $# -lt 1 ]; then
        printUsage " vbox-test-env <Config Dir Path>" " source ./vbox-test-env.sh /path/to/config/dir"
        return 1
    fi
    
    source ${BASEDIR}/libs/common-test-env.sh ${1}
    export -f setCurrentActiveOrg
    export -f unsetActiveOrg
    export -f getOrgIp
    export -f getOrgContainerPort
    export -f getFabricStarterHome
    export -f connectOrgMachine
    export -f copyDirToContainer
    export -f makeDirInContainer
    export -f getFabricStarterHome
    export -f setSpecificEnvVars
}

function connectOrgMachine() {
    local org=${1}
    local domain=${2:-${DOMAIN}}
    eval $(docker-machine env ${org}.${domain})
}

function setCurrentActiveOrg() {

    local org="${1:?Org name is required}"
    export DOMAIN=$(getOrgDomain ${org})
#    local domain=${2:-${DOMAIN}}
    connectMachine ${org} 1>&2 2>/dev/null 1>/dev/null

    export ORG=${org}
    export ORDERER_DOMAIN=$(getOrgOrdererDomain ${org})
    export PEER0_PORT=$(getContainerPort ${org} ${PEER_NAME} ${DOMAIN})
    export PEEER_ORG_NAME=$(getPeerOrgName ${org})
    export PEER_ADDRESS_PREFIX=$(getPeerAddressPrefix ${org})

    printDbg "${BRIGHT}${MAGENTA}setCurrentActiveOrg: Org: ${ORG}, Domain: ${DOMAIN}, ORDERER_DOMAIN: ${ORDERER_DOMAIN}${NORMAL}"


}



function getFabricStarterHome {
    local org=${1}
    local domain=${2:-$(getOrgDomain ${org})}
    echo $(docker-machine ssh ${org}.${domain} pwd)
}


function unsetActiveOrg {
    eval $(docker-machine env -u) >/dev/null
}


function getOrgIp() {
    getOrgIPAddress "${1}"
}


function getOrgContainerPort () {
    local org="${1:?Org name is required}"

    setCurrentActiveOrg "${org}"
    getContainerPort $@
    unsetActiveOrg
}

function makeDirInContainer () {
    local container="${1:?Container name is required}"
    local path="${2:?Directory path is required}"

    dockerMakeDirInContainer ${container} "${path}"
}

function copyDirToContainer () {
    local service="${1}"
    local org=${2}
    local domain=${3}
    local sourcePath="${4:?Source path is required}"
    local destinationPath="${5:?Destination path is required}"

    dockerCopyDirToContainer ${service} ${org} ${domain} "${sourcePath}" "${destinationPath}"
}


function getFabricStarterHome() {
    echo '/home/docker'
}

function setSpecificEnvVars() {
    local org=${1}
    local domain=${2}

    export FABRIC_STARTER_HOME=$(getFabricStarterHome)
    export MY_IP=$(getOrgIPAddress $org)
}

main $@
