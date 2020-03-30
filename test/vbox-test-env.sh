#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source ${BASEDIR}/libs/libs.sh

main() {
    export MULTIHOST=true
    VBOX_HOST_IP=${VBOX_HOST_IP:-$(VBoxManage list hostonlyifs | grep 'IPAddress' | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')}
    export DOCKER_REGISTRY=${VBOX_HOST_IP}:5000
    
    export DEPLOYMENT_TARGET='vbox'
    
    
    
#    local gDomain=$(vbox_guessDomain)
#    local gOrgs=$(vbox_guessOrgs)
    
    if [ $# -lt 2 ]; then
        printUsage " vbox-test-env <DOMAIN> <ORG1> [<ORG2>] [<ORG3>]..." " source ./vbox-test-env.sh ${gDomain} ${gOrgs}"
        return 1
    fi
    
#    printCyan "Local domain '${gDomain}' and '${gOrgs}' orgs found"
    
    
    
    
    source ${BASEDIR}/common-test-env.sh $@
    export -f setCurrentActiveOrg
    export -f resetCurrentActiveOrg
    export -f getOrgIp
    export -f getOrgContainerPort
#    export -f  copyChaincodeToMachine
#    export -f getFabricContainersList
#    export -f getContainersList
    
#    copyChaincodeToMachine ${2} "reference"  #????????
#    copyChaincodeToMachine ${3} "reference"  #TODO
    
}

function setCurrentActiveOrg() {
    local org="${1:?Org name is required}"
    connectMachine ${org} 1>&2
    export $ORG=$org
    export PEER0_PORT=$(getContainerPort ${ORG} ${PEER_NAME} ${DOMAIN})
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

# function copyChaincodeToMachine() {
#     local org=${1}
#     local chaincode=${2}
#     local machine=$(getDockerMachineName ${org})
#     #echo $machine
#     printDbg "${LIGHT}${CYAN}Making a copy of ${chaincode} chaincode on ${machine} for ${org1} ${NORMAL}"
    
    
#     docker-machine scp -r ${FABRIC_DIR}/chaincode/node/${chaincode} ${machine}:/tmp/
#     docker-machine ssh ${machine} ls -al /tmp | printDbg
#     docker-machine ssh ${machine} sudo mkdir -p /home/docker/chaincode/node/$chaincode
#     docker-machine ssh ${machine} sudo cp -r /tmp/${chaincode}/* /home/docker/chaincode/node/${chaincode}
#     docker-machine ssh ${machine} ls -al /home/docker/chaincode/node | printDbg
    
# }


# function getContainersList() {
#     local org=${1}
#     local machine=$(getDockerMachineName ${org})
#     printDbg "Retrieving container list from ${machine} for ${org}"
#     local result=$(docker-machine ssh ${machine} -- sh -c "'docker container ls -a -q | xargs docker container inspect -f \"{{index .NetworkSettings.Networks}} {{.Name}} {{.State.Running}}\"'" |\
#     cut -d '[' -f 2 | cut -d ']' --output-delimiter='' -f 1,2 | cut -d ':' --output-delimiter=' ' -f 1,2,3 | cut -d ' ' -f 1,3,4 | sed -e 's/\///' )

#     set -f
#     IFS=
#     echo "${result}"
#     set +f
# }


main $@
