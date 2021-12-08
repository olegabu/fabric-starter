#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channel=${1}
org=${2}
chaincode_init_name=${CHAINCODE_PREFIX:-reference}
chaincode_name=${3:-${chaincode_init_name}_${channel}}

printToLogAndToScreenBlue "\nVerifing if the test chaincode instantiated in channel [${channel}] channel by [${org}]"
setCurrentActiveOrg ${org}
result=$(runCLIPeer ${org} listChaincodesInstantiated ${channel} ${org} \| grep -E "^$chaincode_name")

setExitCode [ "${result}" = "${chaincode_name}" ]
printResultAndSetExitCode "The test chaincode instantiated in [${channel}] channel by [${org}] org"
