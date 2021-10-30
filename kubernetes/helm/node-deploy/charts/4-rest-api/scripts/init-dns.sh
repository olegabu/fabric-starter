#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || [ -n $BASH_SOURCE ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source $BASEDIR/../lib/container-lib.sh


chaincodePath=${1:?Path to chaincode is requried}

pushd /tmp

CC_LABEL="dns_1.0"
CC_PACKAGE_ID=`peer lifecycle chaincode queryinstalled | grep ${CC_LABEL}`

if [ -z "${CC_PACKAGE_ID}" ]; then

    cp "${chaincodePath}"/connection.json .
    cp "${chaincodePath}"/metadata.json .

    tar czf code.tar.gz connection.json
    tar czf dns.tgz code.tar.gz metadata.json

    peer lifecycle chaincode install dns.tgz

    CC_PACKAGE_ID=`peer lifecycle chaincode queryinstalled | grep dns_1.0`
    CC_PACKAGE_ID=${CC_PACKAGE_ID#*: }
    CC_PACKAGE_ID=${CC_PACKAGE_ID%,*}

    echo "Extracted PACKAGE_ID: ${CC_PACKAGE_ID}"
fi

set -x
echo "$CC_PACKAGE_ID" > /tmp/sharedVol/dns.data
set +x

ls -l /tmp/sharedVol/

popd
