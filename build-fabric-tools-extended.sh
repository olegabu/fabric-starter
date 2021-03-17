#!/usr/bin/env bash
source .env
FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY:-olegabu}
FABRIC_VERSION=${FABRIC_VERSION:-1.4.9}

docker build -t ${FABRIC_STARTER_REPOSITORY}/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest} -f ./fabric-tools-extended/Dockerfile --no-cache --build-arg FABRIC_VERSION=${FABRIC_VERSION} --build-arg FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY} .
