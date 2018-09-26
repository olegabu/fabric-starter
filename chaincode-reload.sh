#!/usr/bin/env bash

n=$1
k=$2
a=$3
p=$4
l=$5
v="1.$RANDOM"

./chaincode-install.sh $n $v $p $l
./chaincode-upgrade.sh $n $k $v $a

echo -e "\e[1;35mUpgraded to version:\e[m \e[1;32m$v\e[m"
