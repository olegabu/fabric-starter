#!/usr/bin/env bash


# adjust ---------------
#export IP_ORDERER=172.18.0.3
export IP2=192.168.56.102
export IP3=192.168.56.102
export ORG1=a
#-----------------------

./network.sh -m down
docker ps -a

./network.sh -m generate-peer -o a -a 4000 -w 8081
./network.sh -m generate-orderer -o a
./network.sh -m up-orderer

./network.sh -m up-one-org -o a -M a -k common
./network.sh -m update-sign-policy -o a -k common

separateLine='-------------------------------------------------------------------------------------\n-------------------------------------------------------------------------------------'
echo -e $separateLine
read -n1 -r -p "Org 'a' is up and joined to channel 'common'. Now on node 'b' generate org 'b' crypto(./network.sh -m generate-peer -o b) and press any key to register org 'b' and in channel 'common'"
./network.sh -m register-new-org -o b -i ${IP2} -k common

echo -e $separateLine
read -n1 -r -p "On node'b' join to channel common (./network.sh -m  join-channel b a common) Press any key to create channel a-b"
./network.sh -m create-channel a "a-b" b

echo -e $separateLine
read -n1 -r -p "On node 'b' join to channel 'a-b' then on node 'c' generate org c crypto (./network.sh -m generate-peer -o c) and Press any key to register org c in channel common"
./network.sh -m register-new-org -o b -i ${IP3} -k common

echo -e $separateLine
echo "Now chaincode 'chaincode_example02' will be installed and instantiated "
./network.sh -m install-chaincode -o a -v 1.0 -n chaincode_example02
./network.sh -m instantiate-chaincode -o a -k a-b -n chaincode_example02

echo -e $separateLine
read -n1 -r -p "Press any key to create channel a-c and a-b-c"
./network.sh -m create-channel a "a-c" c
./network.sh -m create-channel a "a-b-c" b c

echo -e $separateLine
echo "Now on nodes 'b' and 'c' join to channels a-c and a-b-c correspondingly"


