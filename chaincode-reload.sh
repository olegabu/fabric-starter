#!/usr/bin/env bash
source lib.sh
usageMsg="$0 channelName chaincodeName [init args='[]'] [path to chaincode=/opt/chaincode/node/<chaincodeName>] [lang=node]"
exampleMsg="$0 common reference"

IFS=
channelName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
chaincodeName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}

channelName=$1
chaincodeName=$2
a=${3:-'[]'}
p=$4
l=$5
v="1.$RANDOM"

./chaincode-install.sh $chaincodeName $p $v $l
./chaincode-upgrade.sh $channelName $chaincodeName $a $v

printInColor "1;32" "Upgraded to version $v"



