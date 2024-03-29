#!/usr/bin/env bash

source lib.sh


org1=${1:-org1}
domain1=${2:-${DOMAIN:-example.com}}
org2=${3:-org2}
domain2=${4:-${DOMAIN:-example.com}}


: ${RAFT0_CONSENTER_PORT:=7050}
: ${RAFT1_CONSENTER_PORT:=7150}
: ${RAFT2_CONSENTER_PORT:=7250}
: ${RAFT_NODES_COUNT:=3}

#For debug
#export DOCKER_COMPOSE_ORDERER_ARGS="-f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f environments/dev/docker-compose-orderer-debug.yaml"

export RAFT0_CONSENTER_PORT RAFT1_CONSENTER_PORT RAFT2_CONSENTER_PORT RAFT_NODES_COUNT

ORG2_RAFT_NAME_1=raft3
ORG2_RAFT_NAME_2=raft4

./clean.sh


printYellow "1_raft-start-3-nodes: Starting 3 raft nodes on Org1:"
DOMAIN=${domain1} raft/1_raft-start-3-nodes.sh
sleep 1

exit #TODO: Adjust script for new raft-startup approach (in container-orderer.sh)

if [ "$domain1" == "$domain2" ]; then
    printYellow "Delete WWW container to allow new consenter from same domain start flowlessly"
    docker rm -f www.${domain1}
fi

echo -e "\n################# orderer (RAFT0) orderer node for Org2\n"

printYellow "2_raft-prepare-new-consenter.sh: Prepare ORG 2 raft0:"
DOMAIN=${domain2} ORDERER_NAME=${ORG2_RAFT_NAME_1} raft/2_raft-prepare-new-consenter.sh
sleep 1



printYellow "3_raft-add-consenter: Add new consenter info to config:"
DOMAIN=${domain1} raft/3_2_raft-add-consenter.sh ${ORG2_RAFT_NAME_1} ${domain2} ${RAFT0_CONSENTER_PORT}
sleep 5


printYellow "4_raft-start-consenter.sh: Start Org2-raft0, wait for join:"
# skip restarting as in local deployment it's already started and successfully joined at prepare step
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=${ORG2_RAFT_NAME_1} raft/4_raft-start-consenter.sh www.${domain1}
echo "Waitng ${ORG2_RAFT_NAME_1}.${domain2}"

sleep 10

printYellow "5_raft-update-endpoints: Include endpoints ${ORG2_RAFT_NAME_1}.${domain2} to the system-channel"
DOMAIN=${domain1} raft/5_raft-update-endpoints.sh ${ORG2_RAFT_NAME_1} ${domain2} ${RAFT0_CONSENTER_PORT}
sleep 1

echo -e "\n################# RAFT1 orderer node for Org2\n"

if [ "$domain1" == "$domain2" ]; then
    printYellow "Delete WWW container to allow new consenter from same domain start flowlessly"
    docker rm -f www.${domain1}
fi
printYellow "6. Prepare ORG 2 raft4:"
DOMAIN=${domain2} ORDERER_NAME=${ORG2_RAFT_NAME_2} ORDERER_GENERAL_LISTENPORT=${RAFT1_CONSENTER_PORT} raft/2_raft-prepare-new-consenter.sh
sleep 5

printYellow "7. raft-add-consenter.sh: to add ${ORG2_RAFT_NAME_2}.${domain2} to the consenters list"
DOMAIN=${domain1} raft/3_2_raft-add-consenter.sh ${ORG2_RAFT_NAME_2} ${domain2} ${RAFT1_CONSENTER_PORT}
sleep 5

printYellow "8 _raft-start-consenter.sh: Start ${ORG2_RAFT_NAME_2}, wait for join:"
# skip restarting as in local deployment it's already started and successfully joined at prepare step
#DOMAIN=${domain2} ORDERER_NAME=${ORG2_RAFT_NAME_2} ORDERER_GENERAL_LISTENPORT=${RAFT1_CONSENTER_PORT} raft/4_raft-start-consenter.sh www.${domain1}

echo "Waitng ${ORG2_RAFT_NAME_2}.${domain2}"
sleep 10

printYellow "4_raft-update-endpoints: Include endpoints raft4.${domain2} to the system-channel"
DOMAIN=${domain1} raft/5_raft-update-endpoints.sh ${ORG2_RAFT_NAME_2} ${domain2} ${RAFT1_CONSENTER_PORT}


