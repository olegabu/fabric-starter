#!/usr/bin/env bash

source lib.sh
export DNS_CHANNEL="" # avoid auto-create

export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-ports.yaml"
export DOCKER_REGISTRY
export FABRIC_STARTER_VERSION
export SIGNATURE_HASH_FAMILY

first_org=${1:-org1}
orig_orgs=$@

setMachineWorkDir ${first_org}

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
echo -e "\n\nWait first org chaincode is initialized...\n\n"

docker wait post-install.${first_org}.${DOMAIN}

ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./channel-create.sh common
ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./channel-join.sh common
ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./chaincode-instantiate.sh common dns


echo -e "\n\nStart Peers completed. Configure channels...\n\n"
for peerOrg in ${orig_orgs}; do
     ORG_IP=$(getMachineIp ${peerOrg})
     connectMachine ${first_org}
     ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]"
     sleep 3
     if [ "${peerOrg}" != "${first_org}" ]; then
         ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./channel-add-org.sh common ${peerOrg}
         connectMachine ${peerOrg}
         echo -e "\n\nJoin channel common ${peerOrg}.${DOMAIN}"
         ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./channel-join.sh common
         sleep 1
     fi
done

connectMachine ${first_org}
ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./chaincode-install.sh dns 2.0
ORG=${first_org} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./chaincode-upgrade.sh common dns '[]' '2.0' '' 'ANY'

echo -e "\n\nUpgrade chaincode dns...\n\n"
for peerOrg in ${orig_orgs}; do
     if [ "${peerOrg}" != "${first_org}" ]; then
         connectMachine ${peerOrg}
         echo -e "\n\nchaincode-install.sh dns 2.0 ${peerOrg}.${DOMAIN}"
         ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./chaincode-install.sh dns 2.0
         sleep 1
         ORG=${peerOrg} ORDERER_DOMAIN=${ORDERER_DOMAIN} MULTIHOST=true ./chaincode-invoke.sh common dns "[\"registerOrg\", \"${peerOrg}.${DOMAIN}\", \"${ORG_IP}\"]" &
         procId=$!
     fi
done

[ -n ${procId} ] && wait ${procId}