#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source libs/libs.sh

main() {
    if [ $# -lt 1 ]; then
        printUsage " local-test-env <DOMAIN>" " source ./local-test-env.sh example.com"
        return 1
    fi
    
    unset MULTIHOST
    unset DOCKER_REGISTRY
    
    export DEPLOYMENT_TARGET='local'
    
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
  echo 1
}

function getWwwPortDelta() {
  echo 1
}


function getOrgIp() {
    echo $(getDockerGatewayAddress)
}


function getOrgContainerPort () {
    getContainerPort $@
}

function getFabricStarterHome {
  echo "."
}

function setCurrentActiveOrg() {
    local org="${1:?Org name is required}"
    export ORG=${org}
    export PEER0_PORT=$(getContainerPort ${org} ${PEER_NAME} ${DOMAIN})

}

function connectOrgMachine() {
  :
}

function unsetActiveOrg {
    :
}


function getFabricContainersList() {
    local result=$(docker container ls -a -q | xargs -I {} docker container inspect -f "{{index .NetworkSettings.Networks}} {{.Name}} {{.State.Running}}" {} | grep fabric-starter | cut -d ' ' -f 2,3 | sed -e 's/\///')
    set -f
    IFS=
    echo ${result}
    set +f
}

main $@
