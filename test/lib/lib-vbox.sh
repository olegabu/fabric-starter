#!/usr/bin/env bash

function getHostAddress() {
    local org=${1}
    local ip=$(docker-machine ip ${org}.${DOMAIN})
    echo ${ip}
}
