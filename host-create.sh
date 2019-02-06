#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

orgs=${@:-org1}

# Create orderer host machine

info "Creating orderer host $DOCKER_MACHINE_FLAGS"

docker-machine rm orderer --force
docker-machine create ${DOCKER_MACHINE_FLAGS} orderer

# Create member organizations host machines

for org in ${orgs}
do
    info "Creating member organization host $org"
    docker-machine rm ${org} --force
    docker-machine create ${DOCKER_MACHINE_FLAGS} ${org}
done

