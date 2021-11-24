FABRIC_VERSION=${1:-${FABRIC_VERSION:-latest}}
FABRIC_STARTER_VERSION=${2:-${FABRIC_STARTER_VERSION:-latest}}

FABRIC_MAJOR_VERSION=${FABRIC_VERSION%%.*}
FABRIC_MAJOR_VERSION=${FABRIC_MAJOR_VERSION:-1}
VERSION_DIR="${FABRIC_MAJOR_VERSION}x"

set -x
cached=${3-"--no-cache"}

rm chaincode/${VERSION_DIR}/node/dns-chaincode.tgz 2>/dev/null
pushd chaincode/${VERSION_DIR}/node/dns
    npm install
    npm pack
    mv dns-2.0.0.tgz ..
    rm -rf node_modules
    rm package-lock.json
    cd ../
    tar xzf dns-2.0.0.tgz
    rm dns-2.0.0.tgz
    mv package src
    tar czf code.tar.gz src
    rm -rf src
    echo '{"path":"","type":"node","label":"dns_1.0"}' > metadata.json
    tar czf dns-chaincode.tgz code.tar.gz metadata.json
    rm -rf code.tar.gz metadata.json
popd

docker build -t olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION} -f ./fabric-tools-extended/fabric_${FABRIC_MAJOR_VERSION}x.dockerfile ${cached} --build-arg FABRIC_VERSION=${FABRIC_VERSION} .

#rm chaincode/2x/node/dns-chaincode.tgz
set +x