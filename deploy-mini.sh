#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}
first_org=${1:-org1}

docker_compose_args=${DOCKER_COMPOSE_ARGS:-"-f docker-compose-mini.yaml -f docker-compose-mini-ports.yaml"}

export COMPOSE_PROJECT_NAME=${first_org}

export DOCKER_REGISTRY=${DOCKER_REGISTRY:-docker.io}
export FABRIC_VERSION=${FABRIC_VERSION:-1.4.4}
export FABRIC_STARTER_VERSION=${FABRIC_STARTER_VERSION:-latest}
export FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY:-olegabu}

if [ "$DEPLOY_VERSION" == "Hyperledger Fabric 1.4.4-GOST-34" ]; then
    set -x
    export DOCKER_REGISTRY=45.12.73.98
    export FABRIC_VERSION=gost
    export FABRIC_STARTER_VERSION=gost
    export AUTH_MODE=ADMIN
    export CRYPTO_ALGORITHM=GOST
    export SIGNATURE_HASH_FAMILY=SM3

    sudo mkdir -p /etc/docker/certs.d/${DOCKER_REGISTRY}
    openssl s_client -showcerts -connect ${DOCKER_REGISTRY}:443 </dev/null 2>/dev/null|openssl x509 -outform PEM \
        | sudo tee /etc/docker/certs.d/${DOCKER_REGISTRY}/ca.crt
    set +x
fi

if [ -z "${DEV_MODE}" ]; then
    docker pull ${DOCKER_REGISTRY:-docker.io}/${FABRIC_STARTER_REPOSITORY}/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}
    docker pull ${DOCKER_REGISTRY:-docker.io}/${FABRIC_STARTER_REPOSITORY}/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}
fi;

info "Cleaning up"
./clean.sh all


info "Create empty"
echo "docker-compose ${docker_compose_args} up -d"

docker-compose ${docker_compose_args} up -d
docker logs api.${first_org}.${DOMAIN:-example.com}
