#!/usr/bin/env bash

#use org1 host for hosting orderer either
firstOrgMachine=${1:-org1}
ordererMachine=${firstOrgMachine}
shift
export DOMAIN=$DOMAIN

./network-create-base.sh $ordererMachine $firstOrgMachine:$ordererMachine $@

#./network-update-common-dns.sh $ordererMachine $firstOrgMachine:$ordererMachine $@
