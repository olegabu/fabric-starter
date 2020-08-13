#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

channelName=${1}
org=${2}

printToLogAndToScreenCyan "\nInstantiating test chaincode in [${org}]"

JWT=${JWT:-$(APIAuthorize ${org})}

instantiateTestChaincodeAPI ${channelName} ${org} ${JWT} ${TIMEOUT_CHAINCODE_INSTANTIATE}
printResultAndSetExitCode "Test chaincode installed in [${org}]"
