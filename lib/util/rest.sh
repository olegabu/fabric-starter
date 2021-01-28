#!/usr/bin/env bash

function restJWTToken() {
    local restIP=${1?:-IP Addr}
    local user=${2:-user1}
    local pass=${3:-pass}
    echo `(curl -d "{\"username\":\"${user}\",\"password\":\"${pass}\"}" -H "Content-Type: application/json" http://${restIP}/users | tr -d '"')`
}

function restRequest() {
    local jwtToken=${1?:-jwtToken is needed}
    local url=${2?:-Url is needed}
    local postData=${3}

    [ -n "$postData" ] && option=" -d "
    set -x
    curl -H "Authorization: Bearer $jwtToken"  -H "Content-Type: application/json" http://${url} $option "$postData"
    set +x
}

function restChannelCreate() {
    local jwtToken=${1?:-jwtToken is needed}
    local ipAddr=${1?:-ip is needed}
    local postData=${3}
    restRequest $jwtToken "$ipAddr/channels" "$postData"
}

function restChannelJoin() {
    local jwtToken=${1?:-jwtToken is needed}
    local ipAddr=${1?:-ip is needed}
    local channel=${3?:-channel is ndeeded}
    local postData=${4}
    restRequest $jwtToken "$ipAddr/channels/$channel" "$postData"
}

function restChaincodeInstall() {
    local jwtToken=${1?:-jwtToken is needed}
    local ipAddr=${1?:-ip is needed}
    local channel=${3?:-channel is ndeeded}
    local chaincode=${4?:-channel is ndeeded}
    local chaincodeType=${5:-node}
    local postData=${4}
    restRequest $jwtToken "$ipAddr/channels/$channel/chaincodes" "$postData"
}