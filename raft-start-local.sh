#!/usr/bin/env bash
source lib.sh


org1=${1:-org1}
domain1=${2:-example.com}
org2=${3:-org2}
domain2=${4:-example.com}


: ${RAFT0_PORT:=7050}
: ${RAFT1_PORT:=7150}
: ${RAFT2_PORT:=7250}
: ${RAFT_NODES_COUNT:=6}

export RAFT0_PORT RAFT1_PORT RAFT2_PORT RAFT_NODES_COUNT

ORG2_RAFT_NAME_1=raft3
ORG2_RAFT_NAME_2=raft4

./clean.sh

printYellow "1_raft-start-3-nodes: Starting 3 raft nodes on Org1:"
DOMAIN=${domain1} raft/1_raft-start-3-nodes.sh
sleep 20


printYellow "2_raft-prepare-new-consenter.sh: Prepare ORG 2 raft0:"
DOMAIN=${domain2} ORDERER_NAME=${ORG2_RAFT_NAME_1} raft/2_raft-prepare-new-consenter.sh
sleep 5

printYellow "3_raft-add-consenter: Add new consenter info to config:"
DOMAIN=${domain1} ORDERER_NAME=raft0 raft/3_2_raft-add-consenter.sh ${ORG2_RAFT_NAME_1} ${domain2} ${RAFT0_PORT}
sleep 5

#TODO: not need restart first new consenter
#printYellow "4_raft-start-consenter.sh: Start Org2-raft0, wait for join:"
#ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=${ORG2_RAFT_NAME_1} raft/4_raft-start-consenter.sh www.raft0.${domain1}
#echo "Waitng ${ORG2_RAFT_NAME_1}.${domain2}"
#sleep 40

printYellow "5_raft-update-endpoints: Include endpoints ${ORG2_RAFT_NAME_1}.${domain2} to the system-channel"
DOMAIN=${domain1} ORDERER_NAME=raft0 raft/5_raft-update-endpoints.sh ${ORG2_RAFT_NAME_1} ${domain2} ${RAFT0_PORT}

echo -e "\n################# Second orderer node for Org2: raft1\n"

sleep 5
printYellow "6. Prepare ORG 2 raft1:"
DOMAIN=${domain2} ORDERER_NAME=${ORG2_RAFT_NAME_2} raft/2_raft-prepare-new-consenter.sh
sleep 5

printYellow "7. raft-add-consenter.sh: to add raft1 to the consenters list"
DOMAIN=${domain1} ORDERER_NAME=raft0 raft/3_2_raft-add-consenter.sh ${ORG2_RAFT_NAME_2} ${domain2} ${RAFT1_PORT}
sleep 5

printYellow "8 _raft-start-consenter.sh: Start ${ORG2_RAFT_NAME_2}, wait for join:"
DOMAIN=${domain2} ORDERER_NAME=${ORG2_RAFT_NAME_2} ORDERER_GENERAL_LISTENPORT=${RAFT1_PORT} raft/4_raft-start-consenter.sh www.raft0.${domain1}

echo "Waitng raft1.example2.com"
sleep 40

printYellow "4_raft-update-endpoints: Include endpoints raft4.${domain2} to the system-channel"
DOMAIN=${domain1} ORDERER_NAME=raft0 raft/5_raft-update-endpoints.sh ${ORG2_RAFT_NAME_2} ${domain2} ${RAFT1_PORT}


