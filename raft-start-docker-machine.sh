#!/usr/bin/env bash

source lib.sh

orig_orgs=$@

function createHostsFile() {
    local currOrg=${1?:Currentorgisrequired}
    local hosts=""


    # Collect IPs of remote hosts into a hosts file to copy to all hosts to be used as /etc/hosts to resolve all names
    for org in ${orig_orgs}; do
        if [ "$currOrg" != "$org" ]; then
            ip=$(getMachineIp ${org})
            hosts="${hosts}\n${ip} www.${org}-${DOMAIN} orderer.${org}-${DOMAIN} raft1.${org}-${DOMAIN} raft2.${org}-${DOMAIN}"
        fi
    done
    mkdir -p crypto-config/hosts_${currOrg}/crypto-config/
    echo -e ${hosts} > crypto-config/hosts_${currOrg}/crypto-config/hosts
    copyDirToMachine $currOrg crypto-config/hosts_${currOrg}/crypto-config crypto-config
}


export FABRIC_STARTER_VERSION=gost-0.1

: ${RAFT0_PORT:=7050}
: ${RAFT1_PORT:=7150}
: ${RAFT2_PORT:=7250}
: ${RAFT_NODES_COUNT:=3}

export RAFT0_PORT RAFT1_PORT RAFT2_PORT RAFT_NODES_COUNT

######### START ####

first_org=${1:-org1}
shift

orgs=$@

machineName=$first_org

setMachineWorkDir ${machineName}
export FABRIC_STARTER_HOME=${WORK_DIR}
export WWW_PORT=81

BOOTSTRAP_IP=$(getMachineIp ${machineName})
export BOOTSTRAP_IP
export DOCKER_COMPOSE_ORDERER_ARGS="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"
export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-ports.yaml"

ORDERER_DOMAIN_1=${first_org}-${DOMAIN}




#connectMachine ${machineName}
#./clean.sh
#docker pull olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION}
#docker pull olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION}
#
#createHostsFile ${first_org}
#
#printYellow "1_raft-start-3-nodes: Starting 3 raft nodes on Org1:"
#ORDERER_DOMAIN=${ORDERER_DOMAIN_1} raft/1_raft-start-3-nodes.sh
#sleep 2

#
#for org in ${orgs}; do
#
#    ORDERER_DOMAIN_ORG=${org}-${DOMAIN}
#
#    connectMachine ${org}
#
#    ./clean.sh
#    docker pull olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION}
#    docker pull olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION}
#
#    createHostsFile ${org}
#
#    printYellow "2_raft-prepare-new-consenter.sh: Prepare ${org} orderer:"
#    ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} raft/2_raft-prepare-new-consenter.sh
#    sleep 1
#
#    printYellow " 3_raft-add-consenter: Add new consenter to config: "
#    connectMachine ${first_org}
#    ORDERER_DOMAIN=${ORDERER_DOMAIN_1} raft/3_2_raft-add-consenter.sh orderer ${ORDERER_DOMAIN_ORG} ${RAFT0_PORT} ${WWW_PORT}
#
#    printYellow " 4_raft-start-consenter.sh: Start Org2-raft0, wait for join: "
#    connectMachine ${org}
#    ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} raft/4_raft-start-consenter.sh www.${ORDERER_DOMAIN_1}:${WWW_PORT}
#    echo "Waiting  orderer.${ORDERER_DOMAIN_ORG}"
#
#done

docker-compose ${DOCKER_COMPOSE_ARGS} down --volumes

for org in ${orig_orgs}; do

    ORDERER_DOMAIN_ORG=${org}-${DOMAIN}

    MY_IP=$(getMachineIp ${machineName})
    connectMachine ${org}
    ORG=${org} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} WWW_PORT=80 BOOTSTRAP_IP=${BOOTSTRAP_IP} MY_IP=${MY_IP} docker-compose ${DOCKER_COMPOSE_ARGS} up -d --force-recreate

done