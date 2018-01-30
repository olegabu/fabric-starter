# This scenario shows how to create a new channel between and existing org and a
# new org

export CHANNEL_NAME=newchan

mkdir 13
cp configtx.yaml 13
cd 13

# Now modify configtx.yaml so all mentions of Org2 are Org3

# Get cryptomaterial
cp -r ../org3-artifacts/crypto-config .

export FABRIC_CFG_PATH=$PWD

# Create channel configuration tx and peer txs
configtxgen  \
  -profile NewChannel \
  -outputCreateChannelTx ../channel-artifacts/newchan.tx \
  -channelID $CHANNEL_NAME

# Create channel
docker exec cli -it bash

export CHANNEL_NAME=newchan

# Create channel for org1 only

peer channel create \
  -o orderer.example.com:7050 \
  -c $CHANNEL_NAME \
  -f ./channel-artifacts/newchan.tx \
  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Add org3 to the existing channel

CONFIGTXLATOR_URL=http://127.0.0.1:7059
export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=newchan
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

echo '{"payload":{"header":{"channel_header":{"channel_id":"newchan", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

curl -X POST \
  --data-binary @org3_update_in_envelope.json \
  "$CONFIGTXLATOR_URL/protolator/encode/common.Envelope" > org3_update_in_envelope.pb

peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA

# goto org3 container

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=newchan

peer channel fetch 0 newchan.block \
  -o orderer.example.com:7050 \
  -c $CHANNEL_NAME --tls \
  --cafile $ORDERER_CA

peer channel join -b newchan.block

# in cli container as org1

peer channel join -b newchan.block

# ok, now you have two orgs in the same channel
# let's start a chaincode and create a tx

# Instantiate the chaincode

peer chaincode instantiate \
  -o orderer.example.com:7050 \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n mycc -v 1.0 \
  -c '{"Args":["init","a","90","b","210"]}' \
  -P "OR ('Org1MSP.member', 'Org3MSP.member')"

peer chaincode upgrade \
  -o orderer.example.com:7050 \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n mycc -v 2.0 \
  -c '{"Args":["init","a","90","b","210"]}' \
  -P "OR ('Org1MSP.member', 'Org3MSP.member')"


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

# org3 successfully changed the value of a in mycc chaincode

