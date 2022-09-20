#!/usr/bin/env bash
FABRIC_VERSION=${1:-${FABRIC_VERSION:-2.3}}
FABRIC_STARTER_VERSION=${2:-${FABRIC_STARTER_VERSION:-stable}}
FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY:-olegabu}


FABRIC_MAJOR_VERSION=${FABRIC_VERSION%%.*}
FABRIC_MAJOR_VERSION=${FABRIC_MAJOR_VERSION:-1}

[ ${FABRIC_MAJOR_VERSION} -eq 1 ] && CHAINCODE_VERSION_DIR='chaincode' || CHAINCODE_VERSION_DIR="chaincode/${FABRIC_MAJOR_VERSION}x"

set -x
cached=${3-"--no-cache"}

rm ${CHAINCODE_VERSION_DIR}/node/dns-chaincode.tgz 2>/dev/null
pushd ${CHAINCODE_VERSION_DIR}/node/dns
    npm install
    npm pack
    mv dns-*.tgz ../dns-chaincode.tgz
    rm -rf node_modules
    rm package-lock.json
    cd ../
    tar xzf dns-chaincode.tgz
    rm dns-chaincode.tgz
    mv package src
    tar czf code.tar.gz src
    rm -rf src
    echo '{"path":"","type":"node","label":"dns_1.0"}' > metadata.json
    tar czf dns-chaincode.tgz code.tar.gz metadata.json
    rm -rf code.tar.gz metadata.json
popd

docker build -t ${FABRIC_STARTER_REPOSITORY}/fabric-tools-extended:${FABRIC_STARTER_VERSION} -f ./fabric-tools-extended/fabric_${FABRIC_MAJOR_VERSION}x.dockerfile ${cached} --build-arg FABRIC_VERSION=${FABRIC_VERSION} --build-arg FABRIC_STARTER_REPOSITORY=${FABRIC_STARTER_REPOSITORY} .

rm chaincode/2x/node/dns-chaincode.tgz
set +x