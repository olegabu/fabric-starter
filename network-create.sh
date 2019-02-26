#!/usr/bin/env bash

#VM_NAME_PREFIX=${VM_NAME_PREFIX?:-Set environment variable VM_NAME_PREFIX to use for the VM names}

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
}

function copyDirToMachine() {
    machine=$1
    src=$2
    dest=$3

    info "Copying ${src} to remote host ${machine}:${dest}"
    docker-machine ssh ${machine} sudo rm -rf ${dest}
    docker-machine scp -r ${src} ${machine}:${dest}
}

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}

orgs=${@:-org1}
first_org=${1:-org1}

channel=${CHANNEL:-common}
chaincode_install_args=${CHAINCODE_INSTALL_ARGS:-reference}
chaincode_instantiate_args=${CHAINCODE_INSTANTIATE_ARGS:-common reference}
docker_compose_args=${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f couchdb.yaml -f docker-compose-listener.yaml -f multihost.yaml -f ports.yaml}

# Collect IPs of remote hosts into a hosts file to copy to all hosts to be used as /etc/hosts to resolve all names
ordererMachineName=${VM_NAME_PREFIX}orderer
orderer_ip=`(docker-machine ip ${ordererMachineName})`
hosts="127.0.0.1 localhost localhost.local\n${orderer_ip} www.${DOMAIN}\n${orderer_ip} orderer.${DOMAIN}"

export WORK_DIR=`(docker-machine ssh ${ordererMachineName} pwd)`

## Create member organizations host machines

for org in ${orgs}
do
    # collect ip into the hosts file
    orgMachineName=${VM_NAME_PREFIX}${org}
    ip=`(docker-machine ip ${orgMachineName})`
    hosts="${hosts}\n${ip} www.${org}.${DOMAIN}\n${ip} peer0.${org}.${DOMAIN}"
done

echo -e "${hosts}" > hosts

info "Using WORK_DIR=$WORK_DIR on remote host; CHAINCODE_HOME=$CHAINCODE_HOME, WEBAPP_HOME=$WEBAPP_HOME on local host. Hosts file:"
cat hosts

# Copy generated hosts file to the host machines

docker-machine scp hosts ${ordererMachineName}:hosts

for org in ${orgs}
do
    cp hosts org_hosts
    # remove entry of your own ip not to confuse docker and chaincode networking
    sed -i.bak "/.*\.$org\.$DOMAIN*/d" org_hosts
    orgMachineName=${VM_NAME_PREFIX}${org}
    docker-machine scp org_hosts ${orgMachineName}:hosts
    rm org_hosts.bak org_hosts
done

# you may want to keep this hosts file to append to your own local /etc/hosts to simplify name resolution
# rm hosts
# sudo cat hosts >> /etc/hosts

# Create orderer organization

info "Creating orderer organization for $DOMAIN"

copyDirToMachine ${ordererMachineName} templates ${WORK_DIR}/templates

eval "$(docker-machine env ${ordererMachineName})"
./clean.sh
./generate-orderer.sh
docker-compose -f docker-compose-orderer.yaml -f orderer-multihost.yaml up -d

# Create member organizations

for org in ${orgs}
do
    export ORG=${org}

    orgMachineName=${VM_NAME_PREFIX}${org}

    copyDirToMachine ${orgMachineName} templates ${WORK_DIR}/templates
    copyDirToMachine ${orgMachineName} ${CHAINCODE_HOME:-chaincode} ${WORK_DIR}/chaincode
    copyDirToMachine ${orgMachineName} ${WEBAPP_HOME:-webapp} ${WORK_DIR}/webapp

    eval "$(docker-machine env ${orgMachineName})"
    info "Creating member organization $org"
    ./clean.sh
    ./generate-peer.sh
    docker-compose ${docker_compose_args} up -d

    unset ORG
done

# Add member organizations to the consortium

eval "$(docker-machine env ${ordererMachineName})"

for org in ${orgs}
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

# First organization creates the channel

eval "$(docker-machine env ${VM_NAME_PREFIX}${first_org})"
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
./chaincode-install.sh dns
./chaincode-instantiate.sh common dns

# Other organizations join the channel

for org in "${@:2}"
do
    export ORG=${org}
    orgMachineName=${VM_NAME_PREFIX}${org}
    eval "$(docker-machine env ${orgMachineName})"
    info "Joining $org to channel ${channel}"
    ./channel-join.sh ${channel}
    ./chaincode-install.sh ${chaincode_install_args}
    ./chaincode-install.sh dns
    unset ORG
done
