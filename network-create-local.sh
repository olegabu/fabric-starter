#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export DOMAIN=${DOMAIN:-example.com}

orgs=${@:-org1}
first_org=${1:-org1}

channel=${CHANNEL:-common}
chaincode_install_args=${CHAINCODE_INSTALL_ARGS-reference}
chaincode_instantiate_args=${CHAINCODE_INSTANTIATE_ARGS:-common reference}
docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-dev.yaml -f docker-compose-preload-images.yaml}

# Clean up. Remove all containers, delete local crypto material

info "Cleaning up"
./clean.sh
unset ORG COMPOSE_PROJECT_NAME

# Create orderer organization

info "Creating orderer organization for $DOMAIN"
export ORDERER_WWW_PORT=79
WWW_PORT=${ORDERER_WWW_PORT} docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d

# Create member organizations

api_port=${API_PORT:-4000}
export BOOTSTRAP_EXTERNAL_PORT=${BOOTSTRAP_EXTERNAL_PORT:-${API_PORT:-4000}}
export BOOTSTRAP_SERVICE_URL=http

#dev:
www_port=${WWW_PORT:-81}
ca_port=${CA_PORT:-7054}
peer0_port=${PEER0_PORT:-7051}
#

ldap_http=${LDAP_PORT_HTTP:-6080}
ldap_https=${LDAP_PORT_HTTPS:-6443}

custom_port=${CUSTOM_PORT}

sdk_port=${SDK_PORT:-8080}
tls_ca_port=${TLS_CA_PORT:-7155}
external_communication_port=${EXTERNAL_COMMUNICATION_PORT:-443}


for org in ${orgs}
do
    export ORG=${org} API_PORT=${api_port} WWW_PORT=${www_port} PEER0_PORT=${peer0_port} CA_PORT=${ca_port} LDAP_PORT_HTTP=${ldap_http} LDAP_PORT_HTTPS=${ldap_https} CUSTOM_PORT=${custom_port}
    export COMPOSE_PROJECT_NAME=${ORG}
    info "Creating member organization $ORG with api $API_PORT"
    echo "docker-compose ${docker_compose_args} up -d"
    docker-compose ${docker_compose_args} up -d
    info "Wait for post-install.${ORG}.${DOMAIN} completed"
    docker logs -f post-install.${ORG}.${DOMAIN}

    export BOOTSTRAP_ORG_DOMAIN="${org}.${DOMAIN}" BOOTSTRAP_EXTERNAL_PORT=3000
    api_port=$((api_port + 1))
    www_port=$((www_port + 1))
    ca_port=$((ca_port + 1))
    peer0_port=$((peer0_port + 1000))
    ldap_http=$((ldap_http + 100))
    ldap_https=$((ldap_https + 100))
    custom_port=$((custom_port + 1))
    unset ORG COMPOSE_PROJECT_NAME API_PORT WWW_PORT PEER0_PORT CA_PORT LDAP_PORT_HTTP LDAP_PORT_HTTPS CUSTOM_PORT
done

# Add member organizations to the consortium

for org in "${@:2}"
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

