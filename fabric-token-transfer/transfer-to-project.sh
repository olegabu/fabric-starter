#!/usr/bin/env bash
set -e

pushd webapp
au build -e dev
popd

#gradle clean build

echo "Copying files..."

dest="../fabric-starter"

rm -rf $dest/chaincode/*
rm -rf $dest/webapp/*

cp webapp/index.html webapp/favicon.ico $dest/webapp/
cp -r webapp/scripts $dest/webapp/
cp -r webapp/font-awesome/ $dest/webapp/font-awesome/

mkdir -p $dest/webapp/src
cp -r webapp/src/locales $dest/webapp/src

cp -r ./chaincode/* $dest/chaincode/

echo "================================= done ================================="
