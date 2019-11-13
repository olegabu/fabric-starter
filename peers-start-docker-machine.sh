#!/usr/bin/env bash

source lib.sh

export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-ports.yaml"

first_org=${1:-org1}
orig_orgs=$@

setMachineWorkDir ${first_org}
export FABRIC_STARTER_HOME=${WORK_DIR}

BOOTSTRAP_IP=$(getMachineIp ${first_org})
export BOOTSTRAP_IP


echo -e "\n\nPeers with raft: $orig_orgs"
raftIndex=3
for peerOrg in $orig_orgs; do

    ORDERER_DOMAIN_ORG=${first_org}-osn.${DOMAIN}

    if [ "${peerOrg}" == "${first_org}" ]; then
        ORDERER_NAME=orderer
    else
        ORDERER_NAME=raft${raftIndex}
        raftIndex=$((raftIndex+1))
    fi

    bash -c "./peer-start.sh ${peerOrg} ${ORDERER_NAME} ${ORDERER_DOMAIN_ORG}"
#    procId=$!
    sleep 1

done
#wait ${procId}

echo -e "\n\nStart Peers completed. Configure channels...\n\n"

for peerOrg in $orig_orgs; do

    ORDERER_DOMAIN_ORG=${first_org}-osn.${DOMAIN}
    connectMachine ${peerOrg}

    echo -e "\n\nWait for dns chaincode initialized"
    docker wait post-install.${peerOrg}.${DOMAIN}
    sleep 5

    ORG_IP=$(getMachineIp ${peerOrg})
    if [ "${peerOrg}" != "${first_org}" ]; then
        connectMachine ${first_org}

        echo -e "\n\nQuery RegisterOrg ${peerOrg}.${DOMAIN} ${ORG_IP}"
        ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]"

        ORG=${first_org}  ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./channel-add-org.sh common ${peerOrg}

        connectMachine ${peerOrg}
        echo -e "\n\nJoin channel common ${peerOrg}.${DOMAIN}"
        ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./channel-join.sh common
        sleep 5
        echo -e "\n\nQuery RegisterOrg ${peerOrg}.${DOMAIN} ${ORG_IP} ${ORDERER_DOMAIN_ORG}"

        ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN_ORG} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]" &
        procId=$!
        sleep 1
    fi
done
wait ${procId}
