#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channel=${1}
org=${2}
#domain=${3:-${DOMAIN}}
#chaincode=${3} #optional
chaincode_init_name=${CHAINCODE_PREFIX:-reference}
chaincode_name=${3:-${chaincode_init_name}_${channel}}

printToLogAndToScreenBlue "\nVerifing if the test chaincode instantiated in channel [${channel}] channel by [${org}]"

setCurrentActiveOrg ${org}
#verifyChiancodeInstantiated "${channel}" "${org}" "${chaincode}"

    result=$(runCLIPeer ${org} listChaincodesInstantiated ${channel} ${org} 2>/dev/null)
    set -f
    IFS=
    printDbg "Result: ${result}"
    result=$(echo $result  | tr -d "\r" | grep -E "^$chaincode_name")
    set +f

    setExitCode [ "${result}" = "${chaincode_name}" ]


printResultAndSetExitCode "The test chaincode instantiated in [${channel}] channel by [${org}] org"
