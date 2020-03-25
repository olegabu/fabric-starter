#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source libs/libs.sh



main() {

#    local gDomain=$(guessDomain) 
#    local gOrgs=$(guessOrgs)
#channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
    if [ $# -lt 2 ]; then
    printUsage " local-test-env <DOMAIN> <ORG1> [<ORG2>] [<ORG3>]..." " source ./local-test-env.sh ${gDomain} ${gOrgs}"
    return 1
    fi

#    printCyan "Local domain '${gDomain}' and '${gOrgs}' orgs found"

    unset MULTIHOST
    
    export DEPLOYMENT_TARGET='local'

    export -f setCurrentActiveOrg
    export -f resetCurrentActiveOrg
    export -f getOrgIp
    export -f getOrgContainerPort
#    export -f getContainersList
#    export -f getFabricContainersList

    source ${BASEDIR}/common-test-env.sh $@
#    getFabricContainersList
}


function getOrgIp() {
    echo '127.0.0.1'
}

function getOrgContainerPort () {
    getContainerPort $@
}

function setCurrentActiveOrg() {
    local org="${1:?Org name is required}"
    export $ORG=${org}
    export PEER0_PORT=$(getContainerPort ${ORG} ${PEER_NAME} ${DOMAIN})
}

function resetCurrentActiveOrg {
    :
}


function getFabricContainersList() {

local result=$(docker container ls -a -q | xargs -I {} docker container inspect -f "{{index .NetworkSettings.Networks}} {{.Name}} {{.State.Running}}" {} | grep fabric-starter | cut -d ' ' -f 2,3 | sed -e 's/\///')
set -f
IFS=
echo ${result}
set +f
}

# function getContainersList() {
# local org_server=${1}

# local result=$(docker container ls -a -q | xargs -I {} docker container inspect -f "{{index .NetworkSettings.Networks}} {{.Name}} {{.State.Running}}" {} | \
# 	       cut -d '[' -f 2 | cut -d ']' --output-delimiter='' -f 1,2 | cut -d ':' --output-delimiter=' ' -f 1,2,3 | cut -d ' ' -f 1,3,4 | sed -e 's/\///' )

# set -f
# IFS=
# echo ${result}
# set +f
# }



main $@
