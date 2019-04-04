#!/usr/bin/env bash
source lib/util/util.sh
source lib.sh

cleanCryptoMaterial=$1

localRegistryStarted=`runningDockerContainer docker-registry`

if [ -z "$localRegistryStarted" ] ; then
    docker rm -f $(docker ps -aq)
else
    echo "localRegistryStarted=$localRegistryStarted"
    killContainers=`docker ps -aq | sed -e "s/${localRegistryStarted}/ /"`
    echo "killContainers=$killContainers"
    docker rm -f ${killContainers}
fi

#TODO [ "${DOCKER_MACHINE_NAME}" == "orderer" ]  && EXECUTE_BY_ORDERER=1 runCLIWithComposerOverrides down || runCLIWithComposerOverrides down

if [ -z "$cleanCryptoMaterial" ]; then
    docker volume prune -f
    docker rmi -f $(docker images -q -f "reference=dev-*")

    if [ -z "$DOCKER_HOST" ]; then
        docker-compose -f docker-compose-util.yaml run --rm cli.clean rm -rf crypto-config/*
    else
        docker-machine ssh ${DOCKER_MACHINE_NAME} sudo rm -rf crypto-config
        docker-machine ssh ${DOCKER_MACHINE_NAME} sudo rm -rf data/
    fi
fi
#docker rmi -f $(docker images -q -f "reference=olegabu/fabric-starter-client")
#docker network rm `(docker network ls -q)`
