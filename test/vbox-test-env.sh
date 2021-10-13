#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source ${BASEDIR}/libs/libs.sh

main() {
    export MULTIHOST=true
    VBOX_HOST_IP=${VBOX_HOST_IP:-$(VBoxManage list hostonlyifs | grep 'IPAddress' | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')}
    setDocker_LocalRegistryEnv
    export DEPLOYMENT_TARGET='vbox'
    
    if [ $# -lt 1 ]; then
        printYellow "source ./vbox-test-env <DOMAIN>"
        return 1
    fi
    
    source ${BASEDIR}/common-test-env.sh $@
    export -f setCurrentActiveOrg
    export -f unsetActiveOrg
    export -f getOrgIp
    export -f getOrgContainerPort
    export -f getFabricStarterHome
    export -f connectOrgMachine
    export -f getApiPortDelta
    export -f getWwwPortDelta

    source ${BASEDIR}/common-test-env.sh $@
}

function getApiPortDelta() {
  echo 0
}

function getWwwPortDelta() {
  echo 0
}

function setCurrentActiveOrg() {

    local org="${1:?Org name is required}"
    connectMachine ${org} 1>&2 2>/dev/null 1>/dev/null
    export ORG=${org}
    export PEER0_PORT=$(getContainerPort ${ORG} ${PEER_NAME} ${DOMAIN})
}

function connectOrgMachine() {
  local org=${1}
  echo $(docker-machine env ${org}.${DOMAIN})
}

function getFabricStarterHome {
  echo $(docker-machine ssh ${org}.${DOMAIN} pwd)
}


function unsetActiveOrg {
    eval $(docker-machine env -u) >/dev/null
}


function getOrgIp() {
    getMachineIp "${1}"
}


function getOrgContainerPort () {
    local org="${1:?Org name is required}"
    setCurrentActiveOrg "${org}"
    getContainerPort $@
    unsetActiveOrg
}

main $@
