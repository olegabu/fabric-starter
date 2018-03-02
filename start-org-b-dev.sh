#!/usr/bin/env bash

./network.sh -m down
docker ps -a

./network.sh -m generate-peer -o b -e env

read -n1 -r -p "Add org b from org a server and press any key to UP org b..."

./network.sh -m add-org-connectivity -o b -M a -i 192.168.56.101
./network.sh -m up-one-org -o b -M a

read -n1 -r -p "Press any key to join org b to channel common"
./network.sh -m  join-channel b a common

read -n1 -r -p "Press any key to refresh api after adding another org"
./network.sh -m restart-api -o b





#export API_PORT=4001
#export WWW_PORT=8082
#export CA_PORT=8054
#export PEER0_PORT=8051
#export PEER0_EVENT_PORT=8053
#export PEER1_PORT=8056
#export PEER1_EVENT_PORT=8058
