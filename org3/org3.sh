#!/bin/bash

# This sample assumes network.sh has successfully finished creating the network

git clone -b master https://github.com/hyperledger/fabric-samples.git
cd fabric-samples/first-network


# byfn.sh
# - CLI_TIMEOUT=10
# + CLI_TIMEOUT=10000
#
# This will help to save the container for connection

# Create the initial network
./byfn.sh -m generate
./byfn.sh -m up

# Generate artefacts for org3
cd org3-artifacts
cryptogen generate --config=./org3-crypto.yaml
export FABRIC_CFG_PATH=$PWD && \
  configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json
cd ..
cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/

# Enter Docker cli container
docker exec -it cli bash
# ...
export PS1=#\ 

apt update && apt install -y jq

configtxlator start &
sleep 2

CONFIGTXLATOR_URL=http://127.0.0.1:7059
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  && export CHANNEL_NAME=mychannel
echo $ORDERER_CA && echo $CHANNEL_NAME

peer channel fetch config config_block.pb \
  -o orderer.example.com:7050 \
  -c $CHANNEL_NAME \
  --tls \
  --cafile $ORDERER_CA

curl -X POST \
  --data-binary @config_block.pb \
  "$CONFIGTXLATOR_URL/protolator/decode/common.Block" | jq . > config_block.json

jq .data.data[0].payload.data.config config_block.json > config.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ./channel-artifacts/org3.json >& updated_config.json

curl -X POST \
  --data-binary @config.json \
  "$CONFIGTXLATOR_URL/protolator/encode/common.Config" > config.pb

curl -X POST \
  --data-binary @updated_config.json \
  "$CONFIGTXLATOR_URL/protolator/encode/common.Config" > updated_config.pb

curl -X POST \
  -F channel=$CHANNEL_NAME \
  -F "original=@config.pb" \
  -F "updated=@updated_config.pb" \
  "${CONFIGTXLATOR_URL}/configtxlator/compute/update-from-configs" > org3_update.pb

curl -X POST \
  --data-binary @org3_update.pb \
  "$CONFIGTXLATOR_URL/protolator/decode/common.ConfigUpdate" | jq . > org3_update.json

echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

curl -X POST \
  --data-binary @org3_update_in_envelope.json \
  "$CONFIGTXLATOR_URL/protolator/encode/common.Envelope" > org3_update_in_envelope.pb

# You are org1 - just in case smth changed

export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051


# Sign tx by org1
peer channel signconfigtx -f org3_update_in_envelope.pb

# Become org2

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:7051

peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

# Exit the container and join org3 to the channel
docker-compose -f docker-compose-org3.yaml up -d
docker exec -it Org3cli bash

#...
export PS1=#\ 
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=mychannel

# Get the block 0 of mychannel
peer channel fetch 0 mychannel.block \
  -o orderer.example.com:7050 \
  -c $CHANNEL_NAME --tls \
  --cafile $ORDERER_CA

peer channel join -b mychannel.block

# The org3 is the member of the channel "mychannel"

# Let's upgrade the chaincode

peer chaincode install -n mycc -v 2.0 \
  -p github.com/chaincode/chaincode_example02/go/

# Now goto cli container

peer chaincode install -n mycc -v 2.0 \
  -p github.com/chaincode/chaincode_example02/go/

# Become org1

export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

peer chaincode install -n mycc -v 2.0 \
  -p github.com/chaincode/chaincode_example02/go/

# Upgrade the chaincode

peer chaincode upgrade \
  -o orderer.example.com:7050 \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n mycc -v 2.0 \
  -c '{"Args":["init","a","90","b","210"]}' \
  -P "OR ('Org1MSP.member','Org2MSP.member','Org3MSP.member')"

# Verify Org3 has access to the channel and chaincode

peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
peer chaincode invoke \
  -o orderer.example.com:7050  \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n mycc \
  -c '{"Args":["invoke","a","b","10"]}'
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

# End of scenario

