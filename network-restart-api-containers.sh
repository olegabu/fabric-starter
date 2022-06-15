#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export DOMAIN=${DOMAIN:-example.com}

orgs=${@:-org1}
first_org=${1:-org1}

docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-dev.yaml -f docker-compose-preload-images.yaml}

unset ORG COMPOSE_PROJECT_NAME


api_port=${API_PORT:-4000}

#dev:
www_port=${WWW_PORT:-81}
ca_port=${CA_PORT:-7054}
peer0_port=${PEER0_PORT:-7051}
#

ldap_http=${LDAP_PORT_HTTP:-6080}
ldap_https=${LDAP_PORT_HTTPS:-6443}

custom_port=${CUSTOM_PORT}


for org in ${orgs}
do
    export ORG=${org} API_PORT=${api_port} WWW_PORT=${www_port} PEER0_PORT=${peer0_port}
    export COMPOSE_PROJECT_NAME=${ORG}
    info "Restarting rest for org $ORG with api $API_PORT"
    echo "docker-compose ${docker_compose_args} up -d --force-recreate --no-deps api"
    docker-compose ${docker_compose_args} up -d --force-recreate --no-deps api

    api_port=$((api_port + 1))
    www_port=$((www_port + 1))
    peer0_port=$((peer0_port + 1000))
    unset ORG COMPOSE_PROJECT_NAME API_PORT WWW_PORT PEER0_PORT
done

