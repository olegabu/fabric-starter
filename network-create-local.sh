#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export DOMAIN=${DOMAIN-example.com}

# Clean up. Remove all containers, delete local crypto material

info "Cleaning up"
./clean.sh

# Create orderer organization

info "Creating orderer organization for $DOMAIN"
./generate-orderer.sh
docker-compose -f docker-compose-orderer.yaml up -d

# Create member organizations

api_port=${API_PORT-4000}

for org in "$@"
do
    export ORG=${org} API_PORT=${api_port}
    export COMPOSE_PROJECT_NAME=${ORG}
    info "Creating member organization $ORG with api $API_PORT"
    ./generate-peer.sh
    docker-compose up -d
    api_port=$((api_port + 1))
    unset ORG COMPOSE_PROJECT_NAME API_PORT
done

# Add member organizations to the consortium

for org in "$@"
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

# First organization creates common channel

export ORG=${1}
export COMPOSE_PROJECT_NAME=${ORG}

info "Creating channel by $ORG"
./channel-create.sh common
./channel-join.sh common

# First organization adds other organizations to the channel

for org in "${@:2}"
do
    info "Adding $org to the channel"
    ./channel-add-org.sh common ${org}
done

# First organization creates reference chaincode

info "Creating chaincode by $ORG"
./chaincode-install.sh reference
./chaincode-instantiate.sh common reference

# Other organizations join the channel

for org in "${@:2}"
do
    export ORG=${org}
    export COMPOSE_PROJECT_NAME=${ORG}
    info "Joining $org to the channel"
    ./channel-join.sh common
    ./chaincode-install.sh reference
    unset ORG COMPOSE_PROJECT_NAME
done
