#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

export ARGS_PASSED=("$@")
source ../libs/libs.sh

checkArgsPassed

orgs=${@}
DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}

echo "Deploing network for [${DEPLOYMENT_TARGET}] target. Domain: $DOMAIN, Orgs: ${orgs[@]}"
echo "\${DOCKER_REGISTRY} is set to: [${DOCKER_REGISTRY}]"
echo "\${MULTIHOST} is set to: [${MULTIHOST}]"
sleep 2

case "${DEPLOYMENT_TARGET}" in
    
    local)
        unset MULTIHOST
        pushd ../../ >/dev/null
        ./network-create-local.sh ${@}
        popd >/dev/null
    ;;
    vbox)   #dmachine
        pushd ../../ >/dev/null
       ./network-docker-machine-create.sh  ${@}
#        ./network-create.sh  ${@}

        popd >/dev/null
    ;;
    *)
        echo "Wrong target [${DEPLOYMENT_TARGET}]"
    ;;
esac
