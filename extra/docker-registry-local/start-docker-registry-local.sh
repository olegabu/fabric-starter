#!/usr/bin/env bash

: ${FABRIC_VERSION:="latest"}
: ${FABRIC_STARTER_VERSION:="latest"}
: ${JAVA_RUNTIME_VERSION:="latest"}

: ${DOCKER_REGISTRY:=docker.io}
: ${DOCKER_REGISTRY_LOCAL:=localhost:5000}
: ${FABRIC_STARTER_REPOSITORY:-olegabu}

echo "Using local docker registry address: $DOCKER_REGISTRY_LOCAL"

unset DOCKER_HOST DOCKER_MACHINE_NAME DOCKER_CERT_PATH DOCKER_HOST DOCKER_TLS_VERIFY

BASEDIR=$(dirname "$0")

docker-compose -f ${BASEDIR}/docker-compose-local-docker.yaml up -d

#"${DOCKER_REGISTRY}/hyperledger/fabric-baseimage:amd64-0.4.15"
#    "${DOCKER_REGISTRY}/hyperledger/fabric-baseimage:latest" \
#    "${DOCKER_REGISTRY}/hyperledger/fabric-baseos" \
#    "${DOCKER_REGISTRY}/hyperledger/fabric-javaenv:${FABRIC_VERSION}" \

dockerImages=(\
    "hyperledger/fabric-ccenv:${FABRIC_VERSION}" \
    "hyperledger/fabric-orderer:${FABRIC_VERSION}" \
    "hyperledger/fabric-peer:${FABRIC_VERSION}" \
    "hyperledger/fabric-ca:${FABRIC_VERSION}" \
    "hyperledger/fabric-couchdb" \
    "nginx" \
    "${FABRIC_STARTER_REPOSITORY:-olegabu}/fabric-starter-rest:${FABRIC_STARTER_VERSION:-stable}" \
    "${FABRIC_STARTER_REPOSITORY:-olegabu}/fabric-tools-extended:${FABRIC_STARTER_VERSION:-stable}"
#    "apolubelov/fabric-scalaenv:${JAVA_RUNTIME_VERSION:-latest}"
    )

function checkError() {
    local errCode=$?
    [ "$errCode" -ne 0 ] && echo "Return Code $errCode" && exit 1
}

for image in "${dockerImages[@]}"
do
    docker pull ${DOCKER_REGISTRY}/${image}
    checkError
    docker tag ${DOCKER_REGISTRY}/${image} "${DOCKER_REGISTRY_LOCAL}/${image}"
    checkError
    docker push ${DOCKER_REGISTRY_LOCAL}/${image}
    checkError
done
