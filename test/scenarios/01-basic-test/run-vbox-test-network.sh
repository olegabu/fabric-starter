#!/usr/bin/env bash

VBOX_HOST_IP=${VBOX_HOST_IP:-$(VBoxManage list hostonlyifs | grep 'IPAddress' | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')}
export DOCKER_REGISTRY=${VBOX_HOST_IP}:5000

echo "Docker registry set to: $DOCKER_REGISTRY"

pushd ../../../

./network-docker-machine-create.sh org1 org2

popd