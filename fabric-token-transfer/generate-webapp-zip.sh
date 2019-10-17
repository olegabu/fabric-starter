#!/usr/bin/env bash

pushd ..
    rm -rf build/token-transfer
    mkdir -p build/token-transfer

    cp fabric-token-transfer-webapp/index.html build/token-transfer
    cp -r fabric-token-transfer-webapp/favicon.ico build/token-transfer
    cp -r fabric-token-transfer-webapp/scripts  build/token-transfer
    cp -r fabric-token-transfer-webapp/font-awesome/ build/token-transfer/font-awesome
    cp -r fabric-token-transfer-webapp/src/locales build/token-transfer/src

    pushd build
        zip -r token-transfer.zip token-transfer
        rm -rf token-transfer
    popd
popd
