# This scenario tests data is preserved during chaincode upgrade
# Default example uses chaincode with single init method. I have modified it
# to support upgrade transaction

# https://github.com/lexsys27/fabric/blob/fc70c396b60d57732db730adecbf1aff6bbd294a/examples/chaincode/go/chaincode_example02/chaincode_example02.go

docker exec -it cli bash

cd $GOPATH/src/github.com/chaincode/
mkdir ex2
wget https://raw.githubusercontent.com/lexsys27/fabric/fc70c396b60d57732db730adecbf1aff6bbd294a/examples/chaincode/go/chaincode_example02/chaincode_example02.go
mv chaincode_example02.go ex2/ex2.go

# Paste or download the chaincode example to the file ex2.go

peer chaincode install -n upcc -v 1.0 \
  -p github.com/chaincode/ex2

# become org2


export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=peer0.org2.example.com:7051

peer chaincode install -n upcc -v 1.0 \
  -p github.com/chaincode/ex2

# goto org3 cli

peer chaincode install -n upcc -v 1.0 \
  -p github.com/chaincode/ex2

# Init with default values

peer chaincode instantiate \
  -o orderer.example.com:7050 \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n upcc -v 1.0 \
  -c '{"Args":["init","a","90","b","210"]}' \
  -P "OR ('Org1MSP.member','Org2MSP.member','Org3MSP.member')"


peer chaincode query \
  -C $CHANNEL_NAME \
  -n upcc \
  -c '{"Args":["query","a"]}'

# Make a change to the state

peer chaincode invoke \
  -o orderer.example.com:7050  \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n upcc \
  -c '{"Args":["invoke","a","b","10"]}'

peer chaincode query -C $CHANNEL_NAME -n upcc -c '{"Args":["query","a"]}'

# Now install new version of the chaincode to all the peers

# In org3 cli

peer chaincode install -n upcc -v 2.0 \
  -p github.com/chaincode/ex2

# In org2

peer chaincode install -n upcc -v 2.0 \
  -p github.com/chaincode/ex2

# become org1

export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

peer chaincode install -n upcc -v 2.0 \
  -p github.com/chaincode/ex2

# Upgrade the chaincode

peer chaincode upgrade \
  -o orderer.example.com:7050 \
  --tls $CORE_PEER_TLS_ENABLED \
  --cafile $ORDERER_CA \
  -C $CHANNEL_NAME \
  -n upcc -v 2.0 \
  -c '{"Args":["migrate"]}' \
  -P "OR ('Org1MSP.member','Org2MSP.member','Org3MSP.member')"

# Check the data

peer chaincode query -C $CHANNEL_NAME -n upcc -c '{"Args":["query","a"]}'

# The date is the same - it is preserved during the chaincode upgrade

