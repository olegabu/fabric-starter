#!/usr/bin/env bash
source lib/util/util.sh

if [ -z "$DOCKER_MACHINE_FLAGS" ]; then
    localRegistryRunning=`localHostRunningDockerContainer docker-registry`
    if [ -n "$localRegistryRunning" ]; then export DOCKER_REGISTRY=${DOCKER_REGISTRY-"`virtualboxHostIpAddr`:5000"}; fi
fi

./host-create.sh ${@}

./network-create.sh ${@}
