#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export DOMAIN=${DOMAIN-example.com}

orgs=${@:-org1}
first_org=${1:-org1}

channel=${CHANNEL:-common}
chaincode_install_args=${CHAINCODE_INSTALL_ARGS:-reference}
chaincode_instantiate_args=${CHAINCODE_INSTANTIATE_ARGS:-common reference}
docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f couchdb.yaml -f docker-compose-api-port.yaml}

# Clean up. Remove all containers, delete local crypto material

info "Cleaning up"
./clean.sh
unset ORG COMPOSE_PROJECT_NAME

# Create orderer organization

info "Creating orderer organization for $DOMAIN"
docker-compose -f docker-compose-orderer.yaml up -d

# Create member organizations

api_port=${API_PORT:-4000}

for org in ${orgs}
do
    export ORG=${org} API_PORT=${api_port}
    export COMPOSE_PROJECT_NAME=${ORG}
    info "Creating member organization $ORG with api $API_PORT"
    docker-compose ${docker_compose_args} up -d
    api_port=$((api_port + 1))
    unset ORG COMPOSE_PROJECT_NAME API_PORT
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

for org in "${@:2}"
do
    info "Adding $org to channel ${channel}"
    ./channel-add-org.sh ${channel} ${org}
done

# First organization creates the chaincode

info "Creating chaincode by $ORG: ${chaincode_install_args} ${chaincode_instantiate_args}"
./chaincode-install.sh ${chaincode_install_args}
./chaincode-instantiate.sh ${chaincode_instantiate_args}

# Other organizations join the channel

for org in "${@:2}"
do
    export ORG=${org}
    export COMPOSE_PROJECT_NAME=${ORG}
    info "Joining $org to channel ${channel}"
    ./channel-join.sh ${channel}
    ./chaincode-install.sh ${chaincode_install_args}
    unset ORG COMPOSE_PROJECT_NAME
done
