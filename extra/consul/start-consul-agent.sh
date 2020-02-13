#!/usr/bin/env bash

MY_IP=${1:?Extrenal IP is specified}
BOOTSTRAP_IP=$2

if [ -z "$BOOTSTRAP_IP" ]; then

    echo -e "\nBootstrap IP is not specified. Starting new cluster...\n"

    docker-compose -f consul-dns.yaml up
fi