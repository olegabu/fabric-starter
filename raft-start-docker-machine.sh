#!/usr/bin/env bash

source lib.sh

orig_orgs=$@

function createHostsFile() {
    local currOrg=${1?:Current org isrequired}
    local hosts=""


    # Collect IPs of remote hosts into a hosts file to copy to all hosts to be used as /etc/hosts to resolve all names
    for org in ${orig_orgs}; do
        if [ "$currOrg" != "$org" ]; then
            ip=$(getMachineIp ${org})
            hosts="${hosts}\n${ip} www.${org}-osn.${DOMAIN} orderer.${org}-osn.${DOMAIN} raft1.${org}-osn.${DOMAIN} raft2.${org}-osn.${DOMAIN}"
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

export DOMAIN=testnet.aft
export RAFT0_PORT RAFT1_PORT RAFT2_PORT RAFT_NODES_COUNT

######### START ####

first_org=${1:-org1}
shift
orgs=$@


setMachineWorkDir ${first_org}
export FABRIC_STARTER_HOME=${WORK_DIR}
export WWW_PORT=81

BOOTSTRAP_IP=$(getMachineIp ${first_org})
export BOOTSTRAP_IP
export DOCKER_COMPOSE_ORDERER_ARGS="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml"
export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-ports.yaml"
ORDERER_DOMAIN_1=${first_org}-osn.${DOMAIN}


for org in ${orig_orgs}; do
    connectMachine ${org}
    ./clean.sh
    docker pull olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION}
    docker pull olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION}
    createHostsFile ${org}
done


connectMachine ${first_org}
createHostsFile ${first_org}

echo -e "\n\n"
printYellow "1_raft-start-3-nodes: Starting 3 raft nodes on Org1:"
ORDERER_DOMAIN=${ORDERER_DOMAIN_1} raft/1_raft-start-3-nodes.sh
sleep 2

IFS=', ' read -r -a orgsArr <<< "$orgs"
echo -e "\n\n Raft: ${orgsArr[@]:0:3}"
for currOrg in ${orgsArr[@]:0:3}; do

    ORDERER_DOMAIN_ORG=${currOrg}-osn.${DOMAIN}

    connectMachine ${currOrg}

    printYellow "2_raft-prepare-new-consenter.sh: Prepare ${currOrg} orderer:"
    ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} raft/2_raft-prepare-new-consenter.sh
    sleep 1

    printYellow " 3_raft-add-consenter ${currOrg}: Add new consenter to config: "
    connectMachine ${first_org}
    ORDERER_DOMAIN=${ORDERER_DOMAIN_1} raft/3_2_raft-add-consenter.sh orderer ${ORDERER_DOMAIN_ORG} ${RAFT0_PORT} ${WWW_PORT}
    sleep 5
    printYellow " 4_raft-start-consenter.sh ${currOrg}: Start Org2-raft0, wait for join: "
    connectMachine ${currOrg}
    ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} raft/4_raft-start-consenter.sh www.${ORDERER_DOMAIN_1}:${WWW_PORT}
    echo "Waiting  orderer.${ORDERER_DOMAIN_ORG}"
    sleep 5
done

IFS=', ' read -r -a allOrgsArr <<< "$orig_orgs"
echo -e "\n\nPeers with raft: ${allOrgsArr[@]:0:4}"
for peerOrg in ${allOrgsArr[@]:0:4}; do

    ORDERER_DOMAIN_ORG=${peerOrg}-osn.${DOMAIN}
    connectMachine ${peerOrg}
    docker-compose ${DOCKER_COMPOSE_ARGS} down --volumes

    ORG_IP=$(getMachineIp ${peerOrg})
    connectMachine ${peerOrg}
    ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} ORDERER_NAME=orderer WWW_PORT=80 BOOTSTRAP_IP=${BOOTSTRAP_IP} MY_IP=${ORG_IP} docker-compose ${DOCKER_COMPOSE_ARGS} up -d --force-recreate
    echo -e "\n\nWait for org initialized"
    docker wait post-install.${peerOrg}.${DOMAIN}

    if [ "${peerOrg}" != "${first_org}" ]; then
        connectMachine ${first_org}

        echo -e "\n\nQuery RegisterOrg ${peerOrg}.${DOMAIN} ${ORG_IP}"
        ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN_1} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]"

        ORG=${first_org}  ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./channel-add-org.sh common ${peerOrg}

        connectMachine ${peerOrg}
        echo -e "\n\nJoin channel common ${peerOrg}.${DOMAIN}"
        ORG=${org} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./channel-join.sh common
        sleep 5
        echo -e "\n\nQuery RegisterOrg ${peerOrg}.${DOMAIN} ${ORG_IP} ${ORDERER_DOMAIN_ORG}"

        ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]"
    fi

done
echo -e "\n\nPeers no raft:${orgsArr[@]:4}"
exit
for peerOrg in ${orgsArr[@]:4}; do

    ORDERER_DOMAIN_ORG=${peerOrg}-osn.${DOMAIN}

    docker pull olegabu/fabric-starter-rest:${FABRIC_STARTER_VERSION}

    ORG_IP=$(getMachineIp ${peerOrg})
    connectMachine ${peerOrg}
    ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} WWW_PORT=80 BOOTSTRAP_IP=${BOOTSTRAP_IP} MY_IP=${ORG_IP} docker-compose ${DOCKER_COMPOSE_ARGS} up -d --force-recreate
    echo -e "\n\nWait for org initialized"
    docker wait post-install.${peerOrg}.${DOMAIN}

    if [ "${peerOrg}" != "${first_org}" ]; then
        connectMachine ${first_org}

        echo -e "\n\nQuery RegisterOrg ${peerOrg}.${DOMAIN} ${ORG_IP}"
        ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN_1} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]"

        ORG=${first_org}  ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./channel-add-org.sh common ${peerOrg}

        connectMachine ${peerOrg}
        echo -e "\n\nJoin channel common ${peerOrg}.${DOMAIN}"
        ORG=${org} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./channel-join.sh common
        sleep 5
        echo -e "\n\nQuery RegisterOrg ${peerOrg}.${DOMAIN} ${ORG_IP} ${ORDERER_DOMAIN_ORG}"

        ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]"
    fi

done