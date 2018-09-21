#!/usr/bin/env bash

#./chaincode-install.sh fabric-chaincode-example-gradle /opt/chaincode/java/fabric-chaincode-example-gradle java 1.1
#./chaincode-upgrade.sh common fabric-chaincode-example-gradle '["init","a","10","b","0"]' 1.1

n=$1
p=$2
l=$3
k=$4
a=$5
v="1.$RANDOM"

./chaincode-install.sh $n $p $l $v
./chaincode-upgrade.sh $k $n $a $v