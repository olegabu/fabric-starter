#!/usr/bin/env bash

unset MULTIHOST
export DOCKER_REGISTRY='localhost:5000'

echo "Docker registry set to: ${DOCKER_REGISTRY}"
echo "MULTIHOST var is set to: ${MULTIHOST}"


pushd ../../../

./network-create-local.sh org1 org2

popd