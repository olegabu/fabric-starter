#!/usr/bin/env bash
source lib.sh

channelName=${1:?Usage: ./chaincode-instantiate.sh channelName chaincodeName [init args] [version]}
chaincodeName=${2:?Usage: ./chaincode-instantiate.sh channelName chaincodeName [init args] [version]}
initArguments=${3}
chaincodeVersion=${4}


echo "Instantiate chaincode $channelName $chaincodeName [$initArguments] $chaincodeVersion"
instantiateChaincode "$channelName" "$chaincodeName" "$initArguments" "$chaincodeVersion"