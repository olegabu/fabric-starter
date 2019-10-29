#!/usr/bin/env bash


pushd chaincode/java

zip -r ../../build/token-transfer-chaincode.zip chaincode/java/token-transfer-chaincode

popd