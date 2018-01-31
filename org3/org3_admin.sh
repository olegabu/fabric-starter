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
export ORDERER_CA="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

export CHANNEL_NAME="testchainid"

echo $ORDERER_CA && echo $CHANNEL_NAME

# Become ordered org

export CORE_PEER_LOCALMSPID="OrderedMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/users/Admin\@example.com/msp

peer channel fetch config config_block.pb \
  -o orderer.example.com:7050 \
  -c $CHANNEL_NAME \
  --tls \
  --cafile $ORDERER_CA

curl -X POST \
  --data-binary @config_block.pb \
  "$CONFIGTXLATOR_URL/protolator/decode/common.Block" | jq . > config_block.json

jq .data.data[0].payload.data.config config_block.json > config.json

jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups":{"SampleConsortium": {"groups": {"Org3MSP":.[1]}}}}}}}' config.json ./channel-artifacts/org3.json >& updated_config.json

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

echo '{"payload":{"header":{"channel_header":{"channel_id":"testchainid", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

curl -X POST \
  --data-binary @org3_update_in_envelope.json \
  "$CONFIGTXLATOR_URL/protolator/encode/common.Envelope" > org3_update_in_envelope.pb

peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

# Now org3 has the same rights as org1 and org2
# Let's test it by creating a channel

# On the laptop
export CHANNEL_NAME=agora

mkdir 13
cp configtx.yaml 13
cd 13

# Get cryptomaterial
cp -r ../org3-artifacts/crypto-config .

export FABRIC_CFG_PATH=$PWD

# Create channel configuration tx and peer txs
# Such strange path because ../channel-artefacts is not mounted in org3
configtxgen  \
  -profile NewChannel \
  -outputCreateChannelTx ../org3-artefacts/crypto/newchan.tx \
  -channelID $CHANNEL_NAME

docker-compose -f docker-compose-org3.yaml up -d
docker exec -it Org3cli bash

export PS1=#\
export
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=agora

peer channel create \
  -o orderer.example.com:7050 \
  -c $CHANNEL_NAME \
  -f ./crypto/newchan.tx \
  --tls --cafile $ORDERER_CA

peer channel fetch 0 newchan.block \
  -o orderer.example.com:7050 \
  -c $CHANNEL_NAME --tls \
  --cafile $ORDERER_CA

peer channel join -b newchan.block

# Now let's join org1 peer to this channel
# As org1 from cli container..
docker exec -it cli bash

export CHANNEL_NAME=agora

peer channel fetch 0 newchan.block \
  -o orderer.example.com:7050 \
  -c $CHANNEL_NAME --tls \
  --cafile $ORDERER_CA

peer channel join -b newchan.block

# Next step is to install chaincode and verify rw access

cd $GOPATH/src/github.com/chaincode/
mkdir ex2
wget https://raw.githubusercontent.com/lexsys27/fabric/fc70c396b60d57732db730adecbf1aff6bbd294a/examples/chaincode/go/chaincode_example02/chaincode_example02.go
mv chaincode_example02.go ex2/ex2.go

peer chaincode install -n upcc -v 1.0 \
  -p github.com/chaincode/ex2

peer chaincode instantiate \
  -o orderer.example.com:7050 \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n upcc -v 1.0 \
  -c '{"Args":["init","a","90","b","210"]}' \
  -P "OR ('Org1MSP.member', 'Org3MSP.member')"

# Go to org1

cd $GOPATH/src/github.com/chaincode/
mkdir ex2
wget https://raw.githubusercontent.com/lexsys27/fabric/fc70c396b60d57732db730adecbf1aff6bbd294a/examples/chaincode/go/chaincode_example02/chaincode_example02.go
mv chaincode_example02.go ex2/ex2.go

peer chaincode install -n upcc -v 1.0 \
  -p github.com/chaincode/ex2

peer chaincode query \
  -C $CHANNEL_NAME \
  -n upcc \
  -c '{"Args":["query","a"]}'

# Now back to org3

# Make a change to the state

peer chaincode invoke \
  -o orderer.example.com:7050  \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n upcc \
  -c '{"Args":["invoke","a","b","10"]}'

peer chaincode query -C $CHANNEL_NAME -n upcc -c '{"Args":["query","a"]}'


