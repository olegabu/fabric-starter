#!/usr/bin/env bash


function printInColor() {
    color1=$1
    message1=$2
    color2=$3
    message2=$4
    echo -e "\033[${color1}m${message1}\033[m\033[${color2}m$message2\033[m"
}

function printError() {
    printInColor "1;31" "$1"
}

function printRedYellow() {
    printInColor "1;31" "$1" "1;33" "$2"
}

function grepIpAddr() {
    local text=$1
    echo `echo "$text" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"`
}

function virtualboxHostIpAddr() {
    VBoxManage 1>/dev/null 2>/dev/null
    if [ "$?" -ne 0 ]; then
        printError "VBoxManage is not found. Check correct virtualbox's host address is used \n" >&2
        echo ""
        exit
    fi
    local vboxNetworkName=`VBoxManage list dhcpservers | grep -B 6 "Enabled:        Yes" | grep "NetworkName" | awk '{print $2}'`
    local vboxAddrLine=`VBoxManage list hostonlyifs | grep -B 12 "$vboxNetworkName" | grep -m 1 IPAddress`
    echo `grepIpAddr "$vboxAddrLine"`
}

function runningDockerContainer() {
    local containerName=${1:?Container name expected}
    echo `docker ps -aq -f name=${containerName}`
}

function localHostRunningDockerContainer() {
    unset DOCKER_HOST DOCKER_MACHINE_NAME DOCKER_CERT_PATH DOCKER_HOST DOCKER_TLS_VERIFY
    echo `runningDockerContainer $@`
}

function setDocker_LocalRegistryEnv() {
    if [ -z "$DOCKER_MACHINE_FLAGS" ]; then
        localRegistryRunning=`localHostRunningDockerContainer docker-registry`
        if [ -n "$localRegistryRunning" ]; then
            export DOCKER_REGISTRY=${DOCKER_REGISTRY-"`virtualboxHostIpAddr`:5000"};
            echo -e "\n\nUse DOCKER_REGISTRTY=$DOCKER_REGISTRY\n\n"
        fi
    fi
}

