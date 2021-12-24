#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || [ -n $BASH_SOURCE ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source $BASEDIR/../lib/container-lib.sh
source ././../../../../../../container-scripts/lib/container-lib.sh # fro IDE autocomplete

CHAINCODE_PATH=${1:?Path to chaincode is requried}
CC_LABEL="dns_1.0"

function main () {

    ./container-scripts/wait-port.sh ${ORDERER_NAME} ${ORDERER_GENERAL_LISTENPORT}
    ./container-scripts/wait-port.sh ${PEER_ORG_NAME} ${PEER0_PORT}

    createChannel common
    sleep 3
    joinChannel common
    sleep 2

    pushd ${TMP_DIR:-/tmp}
        printYellow "\n install chaincode from ${CHAINCODE_PATH} \n"
        local CC_PACKAGE_RESULT=`installExternalChaincodeMetadata ${CC_LABEL} ${CHAINCODE_PATH}`
        echo "Installation result: ${CC_PACKAGE_RESULT}"
        packageIdToEnvFile "${CC_PACKAGE_RESULT}" "${CHAINCODE_ENV_FILE}"

        instantiateChaincode common "dns" "$initArguments" "1.0" "$privateCollectionPath" "$endorsementPolicy"

        printYellow  "Result env file:"
        cat ${CHAINCODE_ENV_FILE}

    popd 1>/dev/null
}

function installExternalChaincodeMetadata() {
    local cc_label=${1:?Chaincode label is requried}
    local cc_path=${2:?Chaincode path is requried}
    local cc_package_id=`peer lifecycle chaincode queryinstalled | grep ${cc_label}`

    if [ -z "${cc_package_id}" ]; then

        cp "${cc_path}"/connection.json ./
        cp "${cc_path}"/metadata.json ./

        tar czf code.tar.gz connection.json
        tar czf dns.tgz code.tar.gz metadata.json

        peer lifecycle chaincode install dns.tgz
        sleep 1
        cc_package_id=`peer lifecycle chaincode queryinstalled | grep ${cc_label}`

    fi
    echo ${cc_package_id}
}

function packageIdToEnvFile() {
set -x
    local ccPackageId=${1:?PackageId is required}
    local envFile=${2:?Target file is required}

    ccPackageId=${ccPackageId#*: }
    ccPackageId=${ccPackageId%,*}

#    set -x
    echo "PACKAGE_ID=$ccPackageId" > ${envFile}
    set +x
}

main $@