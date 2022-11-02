#!/usr/bin/env bash

if [ -z "${ORG}" ]; then #TODO: use org_env as in deploy.sh
    echo -e "\n\n\nWarning: Env vars ORG,DOMAIN are not set. Using org1.example.com\n\n\n"
    sleep 5
fi

source lib/util/util.sh
source lib.sh

scope=${1}
localRegistryStarted=`runningDockerContainer docker-registry`
minikubeContainerId=`runningDockerContainer minikube`

if [[ -z "$localRegistryStarted" && -z "$minikubeContainerId" ]]; then
    docker rm -f $(docker ps -aq)
else
    echo "localRegistryStarted=${localRegistryStarted}, minikube=${minikubeContainerId}"
    killContainers=`docker ps -aq`
    if [ -n "${localRegistryStarted}" ]; then
        killContainers=`echo ${killContainers} | sed -e "s/${localRegistryStarted}/ /" `
    fi
    if [ -n "$minikubeContainerId" ]; then
        killContainers=`echo $killContainers | sed -e "s/${minikubeContainerId}/ /" `
    fi
    echo "killContainers=$killContainers"
    docker rm -f ${killContainers}
fi

#TODO [ "${DOCKER_MACHINE_NAME}" == "orderer" ]  && EXECUTE_BY_ORDERER=1 runCLIWithComposerOverrides down || runCLIWithComposerOverrides down

docker volume prune -f
docker rmi -f $(docker images -q -f "reference=dev-*")

if [ -n "$DOCKER_HOST" ] ; then
    export FABRIC_STARTER_HOME=`docker-machine ssh ${ORG}.${DOMAIN:-example.com} pwd`
    echo "FABRIC_STARTER_HOME: ${FABRIC_STARTER_HOME}"
    if [ -z "${FABRIC_STARTER_HOME}" ]; then
        echo "Error: Home dir is not found in remote docker host"
        exit 1
    fi
fi

docker-compose -f docker-compose-clean.yaml run --rm cli.clean sh -c "rm -f crypto-config/hosts; rm -rf crypto-config/hfc-*; exit 0"

if [[ "$scope" == "certs" || -z "$scope"  ]]; then
    docker-compose -f docker-compose-clean.yaml run --rm cli.clean sh -c "rm -rf crypto-config/* /certs/*; exit 0"
fi
if [[ "$scope" == "data" || -z "$scope" ]]; then
    docker-compose -f docker-compose-clean.yaml run --rm cli.clean sh -c "rm -rf data/* appstore/*; exit 0;"
fi

#else
#    docker-machine ssh ${DOCKER_MACHINE_NAME} rm -rf crypto-config/
#    docker-machine ssh ${DOCKER_MACHINE_NAME} mkdir -p crypto-config
#    [ "$all" == "all" ] && docker-machine ssh ${DOCKER_MACHINE_NAME} sudo rm -rf data
#    [ "$all" == "all" ] && docker-machine ssh ${DOCKER_MACHINE_NAME} mkdir -p data
#fi

#docker rmi -f $(docker images -q -f "reference=olegabu/fabric-starter-client")
#docker network rm `(docker network ls -q)`
