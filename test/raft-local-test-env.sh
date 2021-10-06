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
    
    export DEPLOYMENT_TARGET='raft-local'
    export BOOTSTRAP_SERVICE_URL='https'
    export API_PORT=4000
    
    export -f setCurrentActiveOrg
    export -f unsetActiveOrg
    export -f getOrgIp
    export -f getOrgContainerPort
    
    source ${BASEDIR}/common-test-env.sh $@
}


function getOrgIp() {
	echo $(ip addr show | grep "\binet\b.*\bdocker0\b" | awk '{print $2}' | cut -d '/' -f 1)
}


function getOrgContainerPort () {
#    echo $@ > /dev/stderr
    getContainerPort $@
}


function setCurrentActiveOrg() {
    local org="${1:?Org name is required}"
    export ORG=${org}
    export PEER0_PORT=$(getContainerPort ${org} ${PEER_NAME} ${DOMAIN})
    
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
