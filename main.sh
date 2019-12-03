#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=$@
first_org=${1:-org1}

export DOMAIN=${DOMAIN:-example.com}
export SERVICE_CHANNEL=${SERVICE_CHANNEL:-common}


docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f docker-compose-couchdb.yaml -f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-generate-tls-certs-debug.yaml -f https/docker-compose-https-ports.yaml -f environments/dev/docker-compose-debug.yaml -f docker-compose-ldap.yaml}

info "Cleaning up"
./clean.sh
unset ORG COMPOSE_PROJECT_NAME

# Create orderer organization

info "Creating orderer organization for $DOMAIN"
ORDERER_WWW_PORT=79
source ${first_org}_env

#docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION:-latest}
#docker pull ${DOCKER_REGISTRY:-docker.io}/olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION:-latest}

WWW_PORT=${ORDERER_WWW_PORT} docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml -f environments/dev/docker-compose-orderer-debug.yaml up -d

echo "docker-compose ${docker_compose_args} up -d"
source ${first_org}_env;
COMPOSE_PROJECT_NAME=${first_org} docker-compose ${docker_compose_args} up -d

echo -e "\nWait post-install.${first_org}.${DOMAIN} to complete"
docker wait post-install.${first_org}.${DOMAIN}

for org in ${@:2}; do
    source ${org}_env
    info "Creating member organization $ORG with api $API_PORT"
    echo "docker-compose ${docker_compose_args} up -d"
    COMPOSE_PROJECT_NAME=${org} docker-compose ${docker_compose_args} up -d
done

sleep 4
for org in "${@:2}"; do
    source ${org}_env
    orgPeer0Port=${PEER0_PORT}

    info "Adding $org to channel ${SERVICE_CHANNEL}"
    source ${first_org}_env;
    set -x
    COMPOSE_PROJECT_NAME=$first_org ORG=$first_org ./channel-add-org.sh ${SERVICE_CHANNEL} ${org} ${orgPeer0Port}
    set +x

done

