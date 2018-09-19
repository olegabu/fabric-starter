#!/usr/bin/env bash
source lib.sh

chaincodeName=${1:?Usage: ./chaincode-install chaincodeName [chaincodeVersion] [path to chaincode] [lang]}
version=$2
path=$3
lang=$4

echo "Install chaincode $chaincodeName [$version] [$path] [$lang]"
installChaincode "$chaincodeName" "$version" "$path" "$lang"