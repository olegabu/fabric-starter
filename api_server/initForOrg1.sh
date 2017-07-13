#!/bin/bash

APIHOST='http://localhost:4000'
echo
echo "===== Creating channel ====="
echo
curl -s -X POST \
  "$APIHOST/channels" \
  -H "content-type: application/json" \
  -d '{"channelName":"mychannel","channelConfigPath":"../../artifacts/channel/mychannel.tx"}'

sleep 5
echo
echo "===== Adding channel members ====="
echo
curl -s -X POST \
  "$APIHOST/channels/mychannel/peers" \
  -H "content-type: application/json" \
  -d '{"peers": ["localhost:7051","localhost:7056"]}'


sleep 5
echo
echo "===== Uploading smart contract ====="
echo
curl -s -X POST \
  "$APIHOST/chaincodes" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["localhost:7051","localhost:7056"],
	"chaincodeName":"mycc",
	"chaincodePath":"github.com/example_cc",
	"chaincodeVersion":"v0"
  }'

sleep 5
echo
echo "===== Instantiate smart contract ====="
echo
curl -s -X POST \
  "$APIHOST/channels/mychannel/chaincodes" \
  -H "content-type: application/json" \
  -d '{
	"chaincodeName":"mycc",
	"chaincodeVersion":"v0",
	"functionName":"init",
	"args":["a","100","b","200"]
  }'