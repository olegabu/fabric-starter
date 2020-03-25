#!/usr/bin/env bash

    DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}
    echo "Deploing network for <${DEPLOYMENT_TARGET}> target. Domain: $DOMAIN, Orgs: ${ORG1} ${ORG2}"
    echo "\${DOCKER_REGISTRY} is set to: <${DOCKER_REGISTRY}>"
    echo "\${MULTIHOST} is set to: <${MULTIHOST}>"
    sleep 2

    case "${DEPLOYMENT_TARGET}" in

        local)
	    unset MULTIHOST
	    pushd ../../ >/dev/null
	    ./network-create-local.sh ${ORG1} ${ORG2}
	    popd >/dev/null
        ;;
        vbox)
	    pushd ../../ >/dev/null
	    ./network-docker-machine-create.sh  ${ORG1} ${ORG2}
    #VBOX_HOST_IP=${VBOX_HOST_IP:-$(virtualboxHostIpAddr)}
    #REGISTRY="${VBOX_HOST_IP}:5000"
    #export DOCKER_REGISTRY=${DOCKER_REGISTRY:-${REGISTRY}}
 #   copyChaincodeToMachine ${2} "reference"  
  #   copyChaincodeToMachine ${3} "reference"  

	    popd >/dev/null
        ;;
        *) 
        echo "Wrong target <${TARGET}>"
        ;;
    esac
