#!/usr/bin/env bash
source lib.sh


org1=${1:-org1}
domain1=${2:-example1.com}
org2=${3:-org2}
domain2=${4:-example2.com}

./clean.sh
printYellow "1_raft-prepare-consenter.sh: Prepare ORG 2 raft0:"
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft0 ORDERER_NAME_PREFIX=raft raft/1_raft-prepare-consenter.sh

#printYellow "Remove temporal genesis.pb"
#ORG=${org2} DOMAIN=${domain2} EXECUTE_BY_ORDERER=1 runCLI "rm -f crypto-config/configtx/${domain2}/genesis.pb"

printYellow "2_raft-start-3-nodes-and-add-consenter.sh: Starting Org1 raft0-raft2; then add raft0 to the consenters list:"
ORG=${org1} DOMAIN=${domain1} ./raft/2_raft-start-3-nodes-and-add-consenter.sh raft0 ${org2} ${domain2}

printYellow "3_raft-start-consenter.sh: Start raft0, wait for join:"
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft0 ./raft/3_raft-start-consenter.sh www.${org1}.${domain1}

echo "Waitng raft0.${domain2}"
sleep 40

printYellow "4_raft-update-endpoints: Include endpoints raft0.${org2}. ${domain2} to the system-channel"
ORG=${org1} DOMAIN=${domain1} ORDERER_NAME=raft0 ./raft/4_raft-update-endpoints.sh raft0 ${org2} ${domain2}

echo -e "\n################# Second orderer node for Org2: raft1\n"

sleep 5
printYellow "1_raft-prepare-consenter.sh: Prepare ORG 2 raft1:"
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft1 ORDERER_NAME_PREFIX=raft raft/1_raft-prepare-consenter.sh
sleep 5

printYellow "raft-add-consenter.sh: to add raft1 to the consenters list"
ORG=${org1} DOMAIN=${domain1} ORDERER_NAME=raft0 raft/raft-add-consenter.sh raft1 ${org2} ${domain2}
sleep 5

printYellow "3_raft-start-consenter.sh: Start raft1, wait for join:"
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft1 ./raft/3_raft-start-consenter.sh www.${org1}.${domain1}

echo "Waitng raft1.example2.com"
sleep 40

printYellow "4_raft-update-endpoints: Include endpoints raft1.${org2}.${domain2} to the system-channel"
ORG=${org1} DOMAIN=${domain1} ORDERER_NAME=raft0 ./raft/4_raft-update-endpoints.sh raft1 ${org2} ${domain2}


