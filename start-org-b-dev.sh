#!/usr/bin/env bash

# adjust ---------------
export IP1=192.168.56.101
export IP1=127.0.0.1
export IP3=192.168.56.102
#-----------------------

./network.sh -m down
docker ps -a

./network.sh -m generate-peer -o b -R true

separateLine='-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------'
echo -e $separateLine
read -n1 -r -p "Peer material is generated. Now on node 'a' add org 'b' then press any key in this console to UP org b..."
./network.sh -m add-org-connectivity -o b -R a -M a -i ${IP1}
./network.sh -m up-one-org -o b -M a

echo -e $separateLine
read -n1 -r -p "Press any key to join org b to channel common"
./network.sh -m  join-channel b a common

echo -e $separateLine
echo "Chaincode 'chaincode_example02' will be installed"
./network.sh -m install-chaincode -o b -v 1.0 -n chaincode_example02

echo -e $separateLine
read -n1 -r -p "Create channel a-b on node a and press any key to join org b to channel a-b"
./network.sh -m  join-channel b a a-b

echo -e $separateLine
read -n1 -r -p "Make steps on nodes 'c' and 'a' to add org c then press any key to refresh b's api"
./network.sh -m restart-api -o b


