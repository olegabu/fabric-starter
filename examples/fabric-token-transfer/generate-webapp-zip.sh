#!/usr/bin/env bash

rm -rf build/token-transfer
mkdir -p build/token-transfer

cp token-transfer-webapp/index.html build/token-transfer
cp -r token-transfer-webapp/favicon.ico build/token-transfer
cp -r token-transfer-webapp/scripts  build/token-transfer
cp -r token-transfer-webapp/font-awesome/ build/token-transfer/font-awesome
cp -r token-transfer-webapp/src/locales build/token-transfer/src

pushd build
    zip -r token-transfer.zip token-transfer
    rm -rf token-transfer
popd

