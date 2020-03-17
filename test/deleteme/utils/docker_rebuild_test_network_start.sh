#!/usr/bin/env bash
./docker_build_images.sh
pushd ../../
./network-docker-machine-create.sh $@
popd

