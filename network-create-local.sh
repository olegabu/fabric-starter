#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export DOMAIN=${DOMAIN-example.com}

orgs=${@:-org1}
first_org=${1:-org1}

channel=${CHANNEL:-common}
chaincode_install_args=${CHAINCODE_INSTALL_ARGS-reference}
chaincode_instantiate_args=${CHAINCODE_INSTANTIATE_ARGS:-common reference}
docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-ports.yaml}

# Clean up. Remove all containers, delete local crypto material

info "Cleaning up"
./clean.sh
unset ORG COMPOSE_PROJECT_NAME

# Create orderer organization

info "Creating orderer organization for $DOMAIN"
docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml up -d

# Create member organizations

api_port=${API_PORT:-4000}
#dev:
www_port=${WWW_PORT:-81}
ca_port=${CA_PORT:-7054}
peer0_port=${PEER0_PORT:-7051}
#

ldap_http=${LDAP_PORT_HTTP:-6080}
ldap_https=${LDAP_PORT_HTTPS:-6443}


for org in ${orgs}
do
    export ORG=${org} API_PORT=${api_port} WWW_PORT=${www_port} PEER0_PORT=${peer0_port} CA_PORT=${ca_port} LDAP_PORT_HTTP=${ldap_http} LDAP_PORT_HTTPS=${ldap_https}
    export COMPOSE_PROJECT_NAME=${ORG}
    info "Creating member organization $ORG with api $API_PORT"
    echo "docker-compose ${docker_compose_args} up -d"
    docker-compose ${docker_compose_args} up -d
    api_port=$((api_port + 1))
    www_port=$((www_port + 1))
    ca_port=$((ca_port + 1))
    peer0_port=$((peer0_port + 1000))
    ldap_http=$((ldap_http + 100))
    ldap_https=$((ldap_https + 100))
    unset ORG COMPOSE_PROJECT_NAME API_PORT WWW_PORT PEER0_PORT CA_PORT LDAP_PORT_HTTP LDAP_PORT_HTTPS
done

# Add member organizations to the consortium

for org in ${orgs}
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

# First organization creates the channel

export ORG=${first_org}
export COMPOSE_PROJECT_NAME=${ORG}

info "Creating channel ${channel} by $ORG"
./channel-create.sh ${channel}
./channel-join.sh ${channel}

# First organization adds other organizations to the channel

peer0_port=$((${PEER0_PORT:-7051}+1000))

for org in "${@:2}"
do
    info "Adding $org to channel ${channel}"
    ./channel-add-org.sh ${channel} ${org} ${peer0_port}
    peer0_port=$((peer0_port + 1000))
done

# First organization creates the chaincode
if [ -n "${chaincode_install_args}" ]; then
   info "Creating chaincode by $ORG: ${chaincode_install_args} ${chaincode_instantiate_args}"
   ./chaincode-install.sh ${chaincode_install_args}
   ./chaincode-instantiate.sh ${chaincode_instantiate_args}
fi

# Other organizations join the channel

peer0_port=${PEER0_PORT:-7051}

for org in "${@:2}"
do
    export ORG=${org}
    export COMPOSE_PROJECT_NAME=${ORG}
    peer0_port=$((peer0_port + 1000))
    info "Joining $org to channel ${channel}"
    PEER0_PORT=$peer0_port ./channel-join.sh ${channel}
    if [ -n "${chaincode_install_args}" ]; then
        PEER0_PORT=$peer0_port ./chaincode-install.sh ${chaincode_install_args}
    fi
    unset ORG COMPOSE_PROJECT_NAME
done
