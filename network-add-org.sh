#!/usr/bin/env bash

source lib/util/util.sh
source lib.sh

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}

: ${CHANNEL:=common}
: ${CHAINCODE_INSTALL_ARGS:=reference}
: ${CHAINCODE_INSTANTIATE_ARGS:=common reference}
: ${DOCKER_COMPOSE_ARGS:= -f docker-compose.yaml -f docker-compose-couchdb.yaml -f multihost.yaml -f docker-compose-ports.yaml}
: ${CHAINCODE_HOME:=chaincode}
: ${WEBAPP_HOME:=webapp}
: ${MIDDLEWARE_HOME:=middleware}

org=${1}

setDocker_LocalRegistryEnv

# Set WORK_DIR as home dir on remote machine
setMachineWorkDir $org


copyFileToMachine ${org} hosts hosts

copyDirToMachine ${org} templates ${WORK_DIR}/templates
copyDirToMachine ${org} container-scripts ${WORK_DIR}/container-scripts
copyDirToMachine ${org} ${CHAINCODE_HOME} ${WORK_DIR}/${CHAINCODE_HOME}
copyDirToMachine ${org} ${WEBAPP_HOME} ${WORK_DIR}/${WEBAPP_HOME}
copyDirToMachine ${org} ${MIDDLEWARE_HOME} ${WORK_DIR}/${MIDDLEWARE_HOME}

info "Copying dns chaincode to remote machine ${machine}"
machine="$org.$DOMAIN"
docker-machine ssh ${machine} mkdir -p ${WORK_DIR}/chaincode/node
docker-machine scp -r chaincode/node/dns ${machine}:${WORK_DIR}/chaincode/node

connectMachine ${org}

./clean.sh
docker-compose ${DOCKER_COMPOSE_ARGS} up -d

# Install application and dns chaincodes
sleep 10
./chaincode-install.sh ${CHAINCODE_INSTALL_ARGS}
#./chaincode-install.sh dns

## Add member organizations to the consortium
#
#connectMachine orderer
#
#info "Adding $org to the consortium"
#./consortium-add-org.sh ${org}

