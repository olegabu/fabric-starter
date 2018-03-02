#!/usr/bin/env bash

#export IP_ORDERER=172.18.0.3
export IP2=192.168.56.102
export ORG1=a

./network.sh -m down
docker ps -a

./network.sh -m generate-peer -o a -a 4000 -w 8081
./network.sh -m generate-orderer -o a
./network.sh -m up-orderer

./network.sh -m up-one-org -o a -M a -k common
./network.sh -m update-sign-policy -o a -k common


read -n1 -r -p "Generate org b crypto (./network.sh -m generate-peer -o b) and Press any key to register org b in channel common"
./network.sh -m register-new-org -o b -i ${IP2} -k common

read -n1 -r -p "Press any key to create channel a-b"
./network.sh -m create-channel a "a-b" b

read -n1 -r -p "Generate org c crypto (./network.sh -m generate-peer -o c) and Press any key to register org c in channel common"
./network.sh -m register-new-org -o b -i ${IP3} -k common

read -n1 -r -p "Press any key to create channel a-c and a-b-c"
./network.sh -m create-channel a "a-c" c
./network.sh -m create-channel a "a-b-c" b c




