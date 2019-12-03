#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=$@
first_org=${1:-org1}

export DOMAIN=${DOMAIN:-example.com}
export SERVICE_CHANNEL=${SERVICE_CHANNEL:-common}

docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-api-port.yaml -f environments/dev/docker-compose-debug.yaml}

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


ldap_http=${LDAP_PORT_HTTP:-6080}
ldap_https=${LDAP_PORT_HTTPS:-6443}


for org in ${orgs}; do

    source ${org}_env
    info "Creating member organization $ORG with api $API_PORT"
    echo "docker-compose ${docker_compose_args} up -d"
    COMPOSE_PROJECT_NAME=${org} docker-compose ${docker_compose_args} up -d
done

docker wait post-install.${first_org}.${DOMAIN}

for org in "${@:2}"; do
    source ${org}_env
    info "Adding $org to channel ${SERVICE_CHANNEL}"
    COMPOSE_PROJECT_NAME=${org} ORG=$first_org ./channel-add-org.sh ${SERVICE_CHANNEL} ${org} ${PEER0_PORT}
done

