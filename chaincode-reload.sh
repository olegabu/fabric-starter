#!/usr/bin/env bash
source lib.sh
usageMsg="$0 chaincodeName channelName [init args='[]'] [path to chaincode=/opt/chaincode/node/<chaincodeName>] [lang=node]"
exampleMsg="$0 reference common"

IFS=
chaincodeName=${1:?`printUsage "$usageMsg" "$exampleMsg"`}
channelName=${2:?`printUsage "$usageMsg" "$exampleMsg"`}

chaincodeName=$1
channelName=$2
a=$3
p=$4
l=$5
v="1.$RANDOM"

./chaincode-install.sh $chaincodeName $v $p $l
./chaincode-upgrade.sh $chaincodeName $channelName $v $a

printInColor "1;32" "Upgraded to version $v"



