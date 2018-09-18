#!/usr/bin/env bash

./generate-peer.sh

docker-compose -f docker-compose/docker-compose-peer.yaml up
