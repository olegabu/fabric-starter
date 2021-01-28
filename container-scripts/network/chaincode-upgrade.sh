#!/usr/bin/env bash
source container-scripts/lib/container-lib.sh
source ../lib/container-lib.sh 2>/dev/null # for IDE code completion

channelName=${1:?Channel name is required}
chaincodeName=${2:?Chaincode name is required}
initArguments=${3:-'[]'}
chaincodeVersion=${4}
endorsementPolicy=${5}

upgradeChaincode "$channelName" "$chaincodeName" "$initArguments" "$chaincodeVersion" "$endorsementPolicy"
