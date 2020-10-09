#!/usr/bin/env bash
FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY:-olegabu}
FABRIC_VERSION=${FABRIC_VERSION:-latest}

docker build -t ${FABRIC_STARTER_REPOSITORY}/fabric-tools-extended -f ./fabric-tools-extended/Dockerfile --no-cache --build-arg FABRIC_VERSION=${FABRIC_VERSION} --build-arg FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY} .