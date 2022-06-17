#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source libs/libs.sh

main() {
    if [ $# -lt 1 ]; then
        printUsage " local-test-env <Config Dir Path>" " source ./local-test-env.sh /path/to/config/dir"
        return 1
    fi
    
    unset MULTIHOST
    
    export DEPLOYMENT_TARGET='local'
    export NETCONFPATH="$(absDirPath "${1}")"

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

    source ${BASEDIR}/libs/common-test-env.sh ${1}
}

function getOrgIp() {
    echo $(getDockerGatewayAddress)
}


function getFabricStarterHome {
  echo "."
}

function setCurrentActiveOrg() {
    local org="${1:?Org name is required}"

    export ORG=${org}
    export DOMAIN=$(getOrgDomain ${org})
    export ORDERER_DOMAIN=$(getOrgOrdererDomain ${org})
    export PEER0_PORT=$(getContainerPort ${org} ${PEER_NAME} $(getOrgDomain ${org}))
    printDbg "${BRIGHT}${MAGENTA}setCurrentActiveOrg: Org: ${ORG}, Domain: ${DOMAIN}, ORDERER_DOMAIN: ${ORDERER_DOMAIN}${NORMAL}"
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
    echo '.'
}

function setSpecificEnvVars() {
    local org=${1}
    local domain=${2}

    export FABRIC_STARTER_HOME=$(getFabricStarterHome)
    export MY_IP=$(getOrgIp)
}

main $@
