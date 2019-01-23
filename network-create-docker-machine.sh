#!/usr/bin/env bash

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}

orgs=${@:-org1}
first_org=${1:-org1}

channel=${CHANNEL:-common}
chaincode_install_args=${CHAINCODE_INSTALL_ARGS:-reference}
chaincode_instantiate_args=${CHAINCODE_INSTANTIATE_ARGS:-common reference}

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

for org in ${orgs}
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

for org in ${orgs}
do
    cp hosts org_hosts
    # remove entry of your own ip not to confuse docker and chaincode networking
    sed -i.bak "/.*${org}.*/d" org_hosts
    docker-machine scp org_hosts ${org}:hosts
    rm org_hosts org_hosts.bak
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

for org in ${orgs}
do
    export ORG=${org}
    docker-machine scp -r templates ${ORG}:templates
    docker-machine scp -r ${CHAINCODE_HOME:-chaincode} ${ORG}:chaincode
    docker-machine scp -r ${WEBAPP_HOME:-webapp} ${ORG}:webapp
    eval "$(docker-machine env ${ORG})"
    info "Creating member organization $ORG"
    ./generate-peer.sh
    docker-compose -f docker-compose.yaml -f multihost.yaml up -d
    unset ORG
done

# Add member organizations to the consortium

eval "$(docker-machine env orderer)"

for org in ${orgs}
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

# First organization creates the channel

eval "$(docker-machine env ${first_org})"
export ORG=${first_org}

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
    eval "$(docker-machine env ${ORG})"
    info "Joining $org to channel ${channel}"
    ./channel-join.sh ${channel}
    ./chaincode-install.sh ${chaincode_install_args}
    unset ORG
done
