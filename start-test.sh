#!/usr/bin/env bash

#export IP_ORDERER=172.18.0.3
#export IP2=192.168.56.102

./network.sh -m down
docker ps -a

./network.sh -m generate-peer -o a -a 4000 -w 8081
./network.sh -m generate-orderer -o a
./network.sh -m up-orderer

./network.sh -m up-one-org -o a -k common
./network.sh -m update-sign-policy -o a -k common


read -n1 -r -p "Generate org2 crypto (./network.sh -m generate-peer -o <org2>) and Press any key to register org2 in channel common"
./network.sh -m register-new-org -o b -i ${IP2} -k common

./network.sh -m create-channel a "a-b" b

./network.sh -m create-channel a "a-b-c" b c




