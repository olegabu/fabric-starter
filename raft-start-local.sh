#!/usr/bin/env bash
source lib.sh


org1=${1:-org1}
domain1=${2:-example1.com}
org2=${3:-org2}
domain2=${4:-example2.com}

./clean.sh
printYellow "1_raft-prepare-consenter.sh: ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft0 raft/1_raft-prepare-consenter.sh"
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft0 raft/1_raft-prepare-consenter.sh

printYellow "2_raft-start-3-nodes-and-add-consenter.sh: ORG=${org1} DOMAIN=${domain1} ./raft/2_raft-start-3-nodes-and-add-consenter.sh raft0 ${org2} ${domain2}"
ORG=${org1} DOMAIN=${domain1} ./raft/2_raft-start-3-nodes-and-add-consenter.sh raft0 ${org2} ${domain2}

printYellow "3_raft-start-consenter.sh: ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft0 ./raft/3_raft-start-consenter.sh www.${org1}.${domain1}"
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft0 ./raft/3_raft-start-consenter.sh www.${org1}.${domain1}

echo "Waitng raft0.example2.com"
sleep 40

printYellow "4_raft-update-endpoints: raft0 ${org2} ${domain2}"
ORG=${org1} DOMAIN=${domain1} ORDERER_NAME=raft0 ./raft/4_raft-update-endpoints.sh raft0 ${org2} ${domain2}

sleep 5
printYellow "1_raft-prepare-consenter.sh: ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft1 raft/1_raft-prepare-consenter.sh"
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft1 raft/1_raft-prepare-consenter.sh

printYellow "raft-add-consenter.sh: COMPOSE_PROJECT_NAME=raft0.${org1} ORDERER_NAME=raft0 raft/raft-add-consenter.sh raft1 ${org2} ${domain2}"
COMPOSE_PROJECT_NAME=raft0.${org1} ORG=${org1} DOMAIN=${domain1} ORDERER_NAME=raft0 raft/raft-add-consenter.sh raft1 ${org2} ${domain2}

printYellow "3_raft-start-consenter.sh: ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft1 ./raft/3_raft-start-consenter.sh www.${org1}.${domain1}"
ORG=${org2} DOMAIN=${domain2} ORDERER_NAME=raft1 ./raft/3_raft-start-consenter.sh www.${org1}.${domain1}

echo "Waitng raft1.example2.com"
sleep 40

printYellow "4_raft-update-endpoints: raft0 ${org2} ${domain2}"
ORG=${org1} DOMAIN=${domain1} ORDERER_NAME=raft0 ./raft/4_raft-update-endpoints.sh raft1 ${org2} ${domain2}


