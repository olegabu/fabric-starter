#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}
chaincode_init_name=${CHAINCODE_PREFIX:-reference}
chaincodeName=${3:-${chaincode_init_name}_${channelName}}

printToLogAndToScreenBlue "\nVerifing if the test chaincode instantiated in channel [${channelName}] channel by [${org}]"

setCurrentActiveOrg ${org}
sleep 20
result=$(runCLIPeer ${org} listChaincodesInstantiated ${channelName} ${org} \| grep -E "^$chaincodeName")

setExitCode [ ! -z "${result}" ]
printResultAndSetExitCode "The test chaincode instantiated in [${channelName}] channel by [${org}] org"
