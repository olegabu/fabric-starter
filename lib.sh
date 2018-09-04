#!/usr/bin/env bash

: ${DOMAIN:="example.com"}
: ${ORG:="org1"}

function run() {
    echo "$1"    
    docker run --rm -v=$PWD/templates:/templates -v=$PWD/crypto-config:/crypto-config hyperledger/fabric-tools bash -c "$1"   
}
