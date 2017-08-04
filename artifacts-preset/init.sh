#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

ORG1_ENDPOINT='http://localhost:4001'
ORG2_ENDPOINT='http://localhost:4002'

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi
starttime=$(date +%s)

echo
echo
echo "POST request Enroll on Org1  ..."
echo
ORG1_TOKEN=$(curl -s -X POST $ORG1_ENDPOINT/users \
    -H "content-type: application/x-www-form-urlencoded" \
    -d 'username=Jim')
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo $ORG1_TOKEN
echo
echo "ORG1 token is $ORG1_TOKEN"
echo

echo "POST request Enroll on Org2 ..."
echo
ORG2_TOKEN=$(curl -s -X POST $ORG2_ENDPOINT/users \
    -H "content-type: application/x-www-form-urlencoded" \
    -d 'username=Barry')
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
echo $ORG2_TOKEN
echo
echo "ORG2 token is $ORG2_TOKEN"
echo
echo

echo "POST request Create channel  ..."
echo
curl -s -X POST $ORG1_ENDPOINT/channels \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../../artifacts/channel/mychannel.tx"
}'
echo
echo

sleep 2
echo "POST request Join channel on Org1"
echo
curl -s -X POST \
  $ORG1_ENDPOINT/channels/mychannel/peers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["org1/peer2","org1/peer1"]
}'
echo
echo

echo "POST request Join channel on Org2"
echo
curl -s -X POST \
  $ORG2_ENDPOINT/channels/mychannel/peers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
  "peers": ["org2/peer2","org2/peer1"]
}'
echo
echo

sleep 2
echo "POST Install chaincode on Org1"
echo
curl -s -X POST \
  $ORG1_ENDPOINT/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
  "peers": ["org1/peer2","org1/peer1"],
	"chaincodeName":"mycc",
	"chaincodePath":"github.com/example_cc",
	"chaincodeVersion":"v0"
}'
echo
echo

sleep 2
echo "POST Install chaincode on Org2"
echo
curl -s -X POST \
  $ORG2_ENDPOINT/chaincodes \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
  "peers": ["org2/peer2","org2/peer1"],
	"chaincodeName":"mycc",
	"chaincodePath":"github.com/example_cc",
	"chaincodeVersion":"v0"
}'
echo
echo

sleep 10
echo "POST instantiate chaincode on peer1 of Org1"
echo
curl -s -X POST \
  $ORG1_ENDPOINT/channels/mychannel/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"chaincodeName":"mycc",
	"chaincodeVersion":"v0",
	"functionName":"init",
	"args":["a","100","b","200"]
}'
echo
echo

# sleep 10
# echo "POST invoke chaincode on peers of Org1 and Org2"
# echo
# TRX_ID=$(curl -s -X POST \
#   http://localhost:4000/channels/mychannel/chaincodes/mycc \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json" \
#   -d '{
# 	"peers": ["localhost:7051", "localhost:8051"],
# 	"fcn":"move",
# 	"args":["a","b","10"]
# }')
# echo "Transacton ID is $TRX_ID"
# echo
# echo

# echo "GET query chaincode on peer1 of Org1"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer1&fcn=query&args=%5B%22a%22%5D" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Block by blockNumber"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel/blocks/1?peer=peer1" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Transaction by TransactionID"
# echo
# curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer1 \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# ############################################################################
# ### TODO: What to pass to fetch the Block information
# ############################################################################
# #echo "GET query Block by Hash"
# #echo
# #hash=????
# #curl -s -X GET \
# #  "http://localhost:4000/channels/mychannel/blocks?hash=$hash&peer=peer1" \
# #  -H "authorization: Bearer $ORG1_TOKEN" \
# #  -H "cache-control: no-cache" \
# #  -H "content-type: application/json" \
# #  -H "x-access-token: $ORG1_TOKEN"
# #echo
# #echo
# echo "GET query ChainInfo"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels/mychannel?peer=peer1" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Installed chaincodes"
# echo
# curl -s -X GET \
#   "http://localhost:4000/chaincodes?peer=peer1&type=installed" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Instantiated chaincodes"
# echo
# curl -s -X GET \
#   "http://localhost:4000/chaincodes?peer=peer1&type=instantiated" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo

# echo "GET query Channels"
# echo
# curl -s -X GET \
#   "http://localhost:4000/channels?peer=peer1" \
#   -H "authorization: Bearer $ORG1_TOKEN" \
#   -H "content-type: application/json"
# echo
# echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
