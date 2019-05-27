#!/usr/bin/env bash

: ${FABRIC_VERSION:="latest"}
: ${FABRIC_STARTER_VERSION:="latest"}

: ${DOCKER_REGISTRY_LOCAL:=localhost:5000}
echo "Using local docker registry address: $DOCKER_REGISTRY_LOCAL"

unset DOCKER_HOST DOCKER_MACHINE_NAME DOCKER_CERT_PATH DOCKER_HOST DOCKER_TLS_VERIFY

BASEDIR=$(dirname "$0")

docker-compose -f ${BASEDIR}/docker-compose-local-docker.yaml up -d

dockerImages=(\
    "hyperledger/fabric-baseimage:amd64-0.4.14" \
    "hyperledger/fabric-baseimage:latest" \
    "hyperledger/fabric-baseos" \
    "hyperledger/fabric-javaenv:${FABRIC_VERSION}" \
    "hyperledger/fabric-ccenv:${FABRIC_VERSION}" \
    "hyperledger/fabric-orderer:${FABRIC_VERSION}" \
    "hyperledger/fabric-peer:${FABRIC_VERSION}" \
    "hyperledger/fabric-ca:${FABRIC_VERSION}" \
    "hyperledger/fabric-couchdb" \
    "nginx" \
    "olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION}" \
    "olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}" \
    "olegabu/fabric-starter-listener"
    )


function checkError() {
    local errCode=$?
    [ "$errCode" -ne 0 ] && echo "Return Code $errCode" && exit 1
}

for image in "${dockerImages[@]}"
do
    docker pull ${image}
    checkError
    docker tag ${image} "${DOCKER_REGISTRY_LOCAL}/${image}"
    checkError
    docker push ${DOCKER_REGISTRY_LOCAL}/${image}
    checkError
done
