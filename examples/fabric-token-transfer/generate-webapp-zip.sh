#!/usr/bin/env bash

rm -rf build/token-transfer-webapp
mkdir -p build/token-transfer-webapp

cp token-transfer-webapp/index.html build/token-transfer-webapp
cp -r token-transfer-webapp/favicon.ico build/token-transfer-webapp
cp -r token-transfer-webapp/scripts  build/token-transfer-webapp
cp -r token-transfer-webapp/font-awesome/ build/token-transfer-webapp/font-awesome
cp -r token-transfer-webapp/src/locales build/token-transfer-webapp/src

pushd build
    zip -r token-transfer-webapp.zip token-transfer-webapp
    rm -rf token-transfer-webapp
popd

