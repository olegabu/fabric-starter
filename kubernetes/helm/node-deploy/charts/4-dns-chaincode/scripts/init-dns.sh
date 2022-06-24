#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || [ -n $BASH_SOURCE ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source $BASEDIR/../lib/container-lib.sh
source ././../../../../../../container-scripts/lib/container-lib.sh 2>/dev/null # for IDE autocomplete

CHAINCODE_PATH=${1:?Path to chaincode is requried}
CC_LABEL="dns_1.0"
CHAINCODE_ENV_FILE=${CHAINCODE_ENV_FILE:-/tmp/dns.env}

function main () {

    ./container-scripts/wait-port.sh ${ORDERER_NAME} ${ORDERER_GENERAL_LISTENPORT}
    ./container-scripts/wait-port.sh ${PEER_ORG_NAME} ${PEER0_PORT}

    local res=1
    while [ $res -ne 0 ]; do
      createChannel common
      res=$?
    done

    sleep 3
    joinChannel common
    sleep 2

    pushd ${TMP_DIR:-/tmp}
        printYellow "\n install chaincode from ${CHAINCODE_PATH} \n"
        local CC_PACKAGE_RESULT=`installExternalChaincodeMetadata ${CC_LABEL} ${CHAINCODE_PATH}`

        echo "Installation result: ${CC_PACKAGE_RESULT}"
        if [ -n "${CC_PACKAGE_RESULT}" ]; then
          instantiateChaincode common "dns" "$initArguments" "1.0" "$privateCollectionPath" "$endorsementPolicy"
        fi

    popd 1>/dev/null

    printYellow  "Result env file: ${CHAINCODE_ENV_FILE}"
    cat ${CHAINCODE_ENV_FILE}
}

function installExternalChaincodeMetadata() {
    local cc_label=${1:?Chaincode label is requried}
    local cc_path=${2:?Chaincode path is requried}
    local cc_package_id=`peer lifecycle chaincode queryinstalled | grep ${cc_label}`

    if [ -z "${cc_package_id}" ]; then
        cc_exists=false
        cp "${cc_path}"/connection.json ./
        cp "${cc_path}"/metadata.json ./

        tar czf code.tar.gz connection.json
        tar czf dns.tgz code.tar.gz metadata.json

        peer lifecycle chaincode install dns.tgz
        sleep 1
        cc_package_id=`peer lifecycle chaincode queryinstalled | grep ${cc_label}`
        echo ${cc_package_id}
    else
      echo ''
    fi
    packageIdToEnvFile "${cc_package_id}" "${CHAINCODE_ENV_FILE}"

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