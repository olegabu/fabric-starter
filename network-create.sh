#!/usr/bin/env bash

#VM_NAME_PREFIX=${VM_NAME_PREFIX?:-Set environment variable VM_NAME_PREFIX to use for the VM names}

function info() {
    echo -e "************************************************************\n\033[1;33m${1}\033[m\n************************************************************"
#    read -n1 -r -p "Press any key to continue" key
#    echo
}

function copyDirToMachine() {
    machine=$1
    src=$2
    dest=$3

    info "Copying ${src} to remote machine ${machine}:${dest}"
    docker-machine ssh ${machine} sudo rm -rf ${dest}
    docker-machine scp -r ${src} ${machine}:${dest}
}

function copyFileToMachine() {
    machine=$1
    src=$2
    dest=$3

    info "Copying ${src} to remote machine ${machine}:${dest}"
    docker-machine scp ${src} ${machine}:${dest}
}

function connectMachine() {
    o=$1
    eval "$(docker-machine env ${VM_NAME_PREFIX}${o})"
    export ORG=${o}
}

function getMachineIp() {
    o=$1
    echo `(docker-machine ip ${VM_NAME_PREFIX}${o})`
}

function setMachineWorkDir() {
    export WORK_DIR=`(docker-machine ssh orderer pwd)`
}

function createChannelAndAddOthers() {
    c=$1

    connectMachine ${first_org}

    info "Creating channel $c by $ORG"
    ./channel-create.sh ${c}

    # First organization adds other organizations to the channel
    for org in ${orgs}
    do
        if [[ ${org} = ${first_org} ]]; then
            continue
        fi
        info "Adding $org to channel $c"
        ./channel-add-org.sh ${c} ${org}
    done

    # All organizations join the channel
    for org in ${orgs}
    do
        info "Joining $org to channel $c"
        connectMachine ${org}
        ./channel-join.sh ${c}
    done

    connectMachine ${first_org}
}

export MULTIHOST=true
export DOMAIN=${DOMAIN-example.com}

: ${CHANNEL:=common}
: ${CHAINCODE_INSTALL_ARGS:=reference}
: ${CHAINCODE_INSTANTIATE_ARGS:=common reference}
: ${DOCKER_COMPOSE_ARGS:= -f docker-compose.yaml -f couchdb.yaml -f docker-compose-listener.yaml -f multihost.yaml -f ports.yaml}
: ${CHAINCODE_HOME:=chaincode}
: ${WEBAPP_HOME:=webapp}

orgs=${@:-org1}
first_org=${1:-org1}

# Set WORK_DIR as home dir on remote machine
setMachineWorkDir

# Collect IPs of remote hosts into a hosts file to copy to all hosts to be used as /etc/hosts to resolve all names
ip=$(getMachineIp orderer)
hosts="# created by network-create.sh\n${ip} www.${DOMAIN} orderer.${DOMAIN}"

# Create member organizations host machines

# Collect ip into the hosts file
for org in ${orgs}
do
    ip=$(getMachineIp ${org})
    hosts="${hosts}\n${ip} www.${org}.${DOMAIN} peer0.${org}.${DOMAIN}"
done

echo -e "${hosts}" > hosts

info "Using WORK_DIR=$WORK_DIR on remote host; CHAINCODE_HOME=$CHAINCODE_HOME, WEBAPP_HOME=$WEBAPP_HOME on local host. Hosts file:"
cat hosts

# Copy generated hosts file to the host machines

#docker-machine scp hosts ${ordererMachineName}:hosts
copyFileToMachine orderer hosts hosts

for org in ${orgs}
do
    cp hosts org_hosts
    # remove entry of your own ip not to confuse docker and chaincode networking
    sed -i.bak "/.*\.$org\.$DOMAIN*/d" org_hosts
    copyFileToMachine ${org} org_hosts hosts
    rm org_hosts.bak org_hosts
done

# you may want to keep this hosts file to append to your own local /etc/hosts to simplify name resolution
# sudo cat hosts >> /etc/hosts

# Create orderer organization

info "Creating orderer organization for $DOMAIN"

copyDirToMachine orderer templates ${WORK_DIR}/templates

connectMachine orderer
./clean.sh
./generate-orderer.sh
docker-compose -f docker-compose-orderer.yaml -f orderer-multihost.yaml up -d

# Create member organizations

for org in ${orgs}
do
    copyDirToMachine ${org} templates ${WORK_DIR}/templates
    copyDirToMachine ${org} ${CHAINCODE_HOME} ${WORK_DIR}/chaincode
    copyDirToMachine ${org} ${WEBAPP_HOME} ${WORK_DIR}/webapp

    info "Creating member organization $org"
    connectMachine ${org}
    ./clean.sh
    ./generate-peer.sh
    docker-compose ${DOCKER_COMPOSE_ARGS} up -d
done

# Add member organizations to the consortium

connectMachine orderer

for org in ${orgs}
do
    info "Adding $org to the consortium"
    ./consortium-add-org.sh ${org}
done

# First organization creates application channel

createChannelAndAddOthers ${CHANNEL}

# First organization creates common channel if it's not the default application channel

if [[ ${CHANNEL} != common ]]; then
    createChannelAndAddOthers common
fi

# All organizations install application and dns chaincode

for org in ${orgs}
do
    connectMachine ${org}
    info "Installing chaincode to $ORG: $CHAINCODE_INSTALL_ARGS"
    ./chaincode-install.sh ${CHAINCODE_INSTALL_ARGS}
    info "Installing chaincode to $ORG: dns"
    ./chaincode-install.sh dns
done

# First organization instantiates application chaincode

connectMachine ${first_org}

info "Instantiating application chaincode by $ORG: $CHAINCODE_INSTANTIATE_ARGS"
./chaincode-instantiate.sh ${CHAINCODE_INSTANTIATE_ARGS}

# First organization instantiates dns chaincode

info "Instantiating dns chaincode by $ORG"
./chaincode-instantiate.sh common dns

info "Waiting for dns chaincode to build"
sleep 20

# First organization creates entries in dns chaincode

ip=$(getMachineIp orderer)
./chaincode-invoke.sh common dns "[\"put\",\"$ip\",\"www.${DOMAIN} orderer.${DOMAIN}\"]"

for org in ${orgs}
do
    ip=$(getMachineIp ${org})
    ./chaincode-invoke.sh common dns "[\"put\",\"$ip\",\"www.${org}.${DOMAIN} peer0.${org}.${DOMAIN}\"]"
done
