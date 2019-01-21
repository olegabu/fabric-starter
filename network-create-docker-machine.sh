#!/usr/bin/env bash

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}

# Create orderer host machine

docker-machine rm orderer --force
docker-machine create orderer
# start collecting hosts file
orderer_ip=`(docker-machine ip orderer)`
hosts="127.0.0.1 localhost localhost.local\n${orderer_ip} www.${DOMAIN}\n${orderer_ip} orderer.${DOMAIN}"

# Create member organizations host machines

for org in "$@"
do
    docker-machine rm ${org} --force
    docker-machine create ${org}
    # collect ip into the hosts file
    ip=`(docker-machine ip ${org})`
    hosts="${hosts}\n${ip} www.${org}.${DOMAIN}\n${ip} peer0.${org}.${DOMAIN}"
done

# Copy generated hosts file to /etc/hosts on all host machines

echo -e "${hosts}" > hosts
cat hosts

docker-machine scp hosts orderer:hosts

for org in "$@"
do
    cp hosts org_hosts
    sed -i "/.*${org}.*/d" org_hosts
    docker-machine scp org_hosts ${org}:hosts
    rm org_hosts
done

rm hosts

# Create orderer organization

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
    ./generate-peer.sh
    docker-compose -f docker-compose.yaml -f multihost.yaml up -d
    unset ${ORG}
done

# Add member organizations to the consortium

eval "$(docker-machine env orderer)"

for org in "$@"
do
    ./consortium-add-org.sh ${org}
done

# First organization creates common channel and reference chaincode

eval "$(docker-machine env ${1})"
export ORG=${1}

./channel-create.sh common
./channel-join.sh common
./chaincode-install.sh reference
./chaincode-instantiate.sh common reference

# First organization adds other organizations to the channel

for org in "${@:2}"
do
    ./channel-add-org.sh common ${org}
done

# Other organizations join the channel

for org in "${@:2}"
do
    export ORG=${org}
    eval "$(docker-machine env ${ORG})"
    ./channel-join.sh common
    ./chaincode-install.sh reference
    unset ${ORG}
done
