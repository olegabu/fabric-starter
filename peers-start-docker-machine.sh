#!/usr/bin/env bash

source lib.sh

export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-ports.yaml"
export DOCKER_REGISTRY
export FABRIC_STARTER_VERSION

first_org=${1:-org1}
orig_orgs=$@

setMachineWorkDir ${first_org}
export FABRIC_STARTER_HOME=${WORK_DIR}

BOOTSTRAP_IP=$(getMachineIp ${first_org})
export BOOTSTRAP_IP

ORDERER_DOMAIN="${first_org}-osn.${DOMAIN}"

raftIndex=3
for peerOrg in $orig_orgs; do
    if [ "${peerOrg}" == "${first_org}" ]; then
        ORDERER_NAME=orderer
        ./peer-start.sh ${peerOrg} ${ORDERER_NAME} ${ORDERER_DOMAIN}
        sleep 5
    else
        ORDERER_NAME=raft${raftIndex}
        raftIndex=$((raftIndex+1))
        bash -c "./peer-start.sh ${peerOrg} ${ORDERER_NAME} ${ORDERER_DOMAIN}" &
        procId=$!
        sleep 1
    fi
done
[[ -n "${procId}" ]] && wait ${procId}
connectMachine ${first_org}
docker wait post-install.${first_org}.${DOMAIN}

echo -e "\n\nStart Peers completed. Configure channels...\n\n"

for peerOrg in $orig_orgs; do

    echo -e "\n\nWait for dns chaincode initialized"
    ORG_IP=$(getMachineIp ${peerOrg})
    if [ "${peerOrg}" != "${first_org}" ]; then
        connectMachine ${first_org}

        echo -e "\n\nQuery RegisterOrg ${peerOrg}.${DOMAIN} ${ORG_IP}"
        ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]"
        sleep 2
        ORG=${first_org}  ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./channel-add-org.sh common ${peerOrg}

        connectMachine ${peerOrg}
        echo -e "\n\nJoin channel common ${peerOrg}.${DOMAIN}"
        ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./channel-join.sh common
        sleep 5
        echo -e "\n\nQuery RegisterOrg ${peerOrg}.${DOMAIN} ${ORG_IP} ${ORDERER_DOMAIN}"

        ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]" &
        procId=$!
        sleep 1
    fi
done
[[ -n "${procId}" ]] &&  wait ${procId}
