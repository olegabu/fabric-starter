#!/usr/bin/env bash

pushd chaincode/java

zip -r ../../build/token-transfer-chaincode.zip token-transfer-chaincode

popd
