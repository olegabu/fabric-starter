#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}

# Create orderer host machine

info "Creating orderer host $DOCKER_MACHINE_FLAGS"

docker-machine rm orderer --force
docker-machine create ${DOCKER_MACHINE_FLAGS} orderer
# start collecting hosts file
orderer_ip=`(docker-machine ip orderer)`
hosts="127.0.0.1 localhost localhost.local\n${orderer_ip} www.${DOMAIN}\n${orderer_ip} orderer.${DOMAIN}"

export WORK_DIR=`(docker-machine ssh orderer pwd)`

info "Using WORK_DIR=$WORK_DIR on the remote host"

# Create member organizations host machines

for org in "$@"
do
    info "Creating member organization host $org"
    docker-machine rm ${org} --force
    docker-machine create ${DOCKER_MACHINE_FLAGS} ${org}
    # collect ip into the hosts file
    ip=`(docker-machine ip ${org})`
    hosts="${hosts}\n${ip} www.${org}.${DOMAIN}\n${ip} peer0.${org}.${DOMAIN}"
done

# Copy generated hosts file to /etc/hosts on all host machines

echo -e "${hosts}" > hosts

info "Hosts created"
cat hosts

docker-machine scp hosts orderer:hosts

for org in "$@"
do
    cp hosts org_hosts
    # remove entry of your own ip not to confuse docker and chaincode networking
    sed -i "/.*${org}.*/d" org_hosts
    docker-machine scp org_hosts ${org}:hosts
    rm org_hosts
done

# keep this hosts file so you can append to your own /etc/hosts to simplify name resolution
# rm hosts
# sudo cat hosts >> /etc/hosts

# Create orderer organization

info "Creating orderer organization for $DOMAIN"
docker-machine scp -r templates orderer:templates
eval "$(docker-machine env orderer)"
./generate-orderer.sh
docker-compose -f docker-compose-orderer.yaml -f orderer-multihost.yaml up -d

# Create member organizations

for org in "$@"
do
    export ORG=${org}
    docker-machine scp -r templates ${ORG}:templates && docker-machine scp -r chaincode ${ORG}:chaincode && docker-machine scp -r webapp ${ORG}:webapp
    eval "$(docker-machine env ${ORG})"
    info "Creating member organization $ORG"
    ./generate-peer.sh
    docker-compose -f docker-compose.yaml -f multihost.yaml up -d
    unset ORG
done

# Add member organizations to the consortium

eval "$(docker-machine env orderer)"

for org in "$@"
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

# First organization creates common channel and reference chaincode

eval "$(docker-machine env ${1})"
export ORG=${1}

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
    eval "$(docker-machine env ${ORG})"
    info "Joining $org to the channel"
    ./channel-join.sh common
    ./chaincode-install.sh reference
    unset ORG
done
