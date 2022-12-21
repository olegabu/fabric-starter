#!/usr/bin/env bash
FABRIC_VERSION=${1:-${FABRIC_VERSION:-2.3}}
FABRIC_STARTER_VERSION=${2:-${FABRIC_STARTER_VERSION:-stable}}
FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY:-olegabu}

FABRIC_MAJOR_VERSION=${FABRIC_VERSION%%.*}
FABRIC_MAJOR_VERSION=${FABRIC_MAJOR_VERSION:-1}

[ ${FABRIC_MAJOR_VERSION} -eq 1 ] && CHAINCODE_VERSION_DIR='chaincode' || CHAINCODE_VERSION_DIR="chaincode/${FABRIC_MAJOR_VERSION}x"
[ ${FABRIC_MAJOR_VERSION} -eq 1 ] && NODE_IMAGE="${DOCKER_REGISTRY:-docker.io}/hyperledger/fabric-tools:${FABRIC_VERSION:-latest}"

set -x
cached=${3-"--no-cache"}

docker build -t ${FABRIC_STARTER_REPOSITORY}/fabric-tools-extended:${FABRIC_STARTER_VERSION} \
      -f ./fabric-tools-extended/Dockerfile ${cached} \
      --build-arg FABRIC_VERSION=${FABRIC_VERSION} \
      --build-arg FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY} \
      --build-arg NODE_IMAGE=${NODE_IMAGE} \
      --build-arg CHAINCODE_VERSION_DIR=${CHAINCODE_VERSION_DIR} .

set +x
