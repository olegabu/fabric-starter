#!/usr/bin/env bash

rm -rf webapp/*

cp fabric-token-transfer-webapp/index.html webapp
cp -r fabric-token-transfer-webapp/favicon.ico webapp/
cp -r fabric-token-transfer-webapp/scripts  webapp/
cp -r fabric-token-transfer-webapp/font-awesome/ webapp/font-awesome/
cp -r fabric-token-transfer-webapp/src/locales webapp/src
