#!/usr/bin/env bash


pushd ../../

./extra/docker-registry-local/start-docker-registry-local.sh

./build-fabric-tools-extended.sh


docker tag olegabu/fabric-tools-extended localhost:5000/olegabu/fabric-tools-extended
docker push localhost:5000/olegabu/fabric-tools-extended:latest

popd


pushd ../../../fabric-starter-rest 

docker build -t olegabu/fabric-starter-rest --no-cache --build-arg FABRIC_STARTER_VERSION=${FABRIC_STARTER_VERSION:-latest} .
docker tag olegabu/fabric-starter-rest localhost:5000/olegabu/fabric-starter-rest
docker push localhost:5000/olegabu/fabric-starter-rest:latest

popd

