#!/usr/bin/env bash

source lib/util/util.sh
source lib.sh

setDocker_LocalRegistryEnv

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}

: ${CHANNEL:=common}
: ${CHAINCODE_INSTALL_ARGS:=reference}
: ${CHAINCODE_INSTANTIATE_ARGS:=common reference}
: ${DOCKER_COMPOSE_ARGS:= -f docker-compose.yaml -f docker-compose-couchdb.yaml -f multihost.yaml }
: ${CHAINCODE_HOME:=chaincode}
: ${WEBAPP_HOME:=webapp}
: ${MIDDLEWARE_HOME:=middleware}

orgs=${@:-org1}
first_org=${1:-org1}

# Set WORK_DIR as home dir on remote machine
setMachineWorkDir

# Collect IPs of remote hosts into a hosts file to copy to all hosts to be used as /etc/hosts to resolve all names
BOOTSTRAP_IP=$(getMachineIp orderer)
hosts="# created by network-create.sh\n${BOOTSTRAP_IP} www.${DOMAIN} orderer.${DOMAIN}"

export BOOTSTRAP_IP

# Create member organizations host machines

# Collect ip into the hosts file
for org in ${orgs}
do
    ip=$(getMachineIp ${org})
    hosts="${hosts}\n${ip} www.${org}.${DOMAIN} peer0.${org}.${DOMAIN}"
done

echo -e "${hosts}" > hosts

info "Building network for $DOMAIN using WORK_DIR=$WORK_DIR on remote machines, CHAINCODE_HOME=$CHAINCODE_HOME, WEBAPP_HOME=$WEBAPP_HOME on local host. Hosts file:"
cat hosts

# Copy generated hosts file to the host machines

#docker-machine scp hosts ${ordererMachineName}:hosts
copyFileToMachine orderer hosts hosts


# Create orderer organization

info "Creating orderer organization"

copyDirToMachine orderer templates ${WORK_DIR}/templates
copyDirToMachine orderer container-scripts ${WORK_DIR}/container-scripts

connectMachine orderer
./clean.sh
docker-compose -f docker-compose-orderer.yaml -f docker-compose-open-net.yaml -f orderer-multihost.yaml up -d

# Create member organizations

for org in ${orgs}
do

    info "Copying custom chaincodes and middleware to remote machine ${machine}"
    copyDirToMachine ${org} templates ${WORK_DIR}/templates
    copyDirToMachine ${org} ${CHAINCODE_HOME} ${WORK_DIR}/chaincode
    copyDirToMachine ${org} ${WEBAPP_HOME} ${WORK_DIR}/webapp
    copyDirToMachine ${org} ${MIDDLEWARE_HOME} ${WORK_DIR}/middleware

    info "Copying dns chaincode and middleware to remote machine ${machine}"
    machine="$org.$DOMAIN"
    docker-machine scp -r chaincode ${machine}:${WORK_DIR}
    docker-machine scp middleware/dns.js ${machine}:${WORK_DIR}/middleware/dns.js
    copyDirToMachine ${org} container-scripts ${WORK_DIR}/container-scripts

    info "Creating member organization $org"
    connectMachine ${org}
    export ORG_IP=$(getMachineIp ${org})

    ./clean.sh
    createHostsFileInOrg $org
    docker-compose ${DOCKER_COMPOSE_ARGS} up -d
done

