#!/bin/bash

docker tag hyperledger/fabric-tools:x86_64-1.0.0  hyperledger/fabric-tools:latest
docker tag hyperledger/fabric-orderer:x86_64-1.0.0  hyperledger/fabric-orderer:latest
docker tag hyperledger/fabric-peer:x86_64-1.0.0  hyperledger/fabric-peer:latest
docker tag hyperledger/fabric-ca:x86_64-1.0.0  hyperledger/fabric-ca:latest