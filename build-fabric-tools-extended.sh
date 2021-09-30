FABRIC_VERSION=${1:-${FABRIC_VERSION:-latest}}
FABRIC_STARTER_VERSION=${2:-${FABRIC_STARTER_VERSION:-latest}}

FABRIC_MAJOR_VERSION=${FABRIC_VERSION%%.*}
FABRIC_MAJOR_VERSION=${FABRIC_MAJOR_VERSION:-1}

set -x
cached=${3-"--no-cache"}
docker build -t olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION} -f ./fabric-tools-extended/fabric_${FABRIC_MAJOR_VERSION}1.dockerfile ${cached} --build-arg FABRIC_VERSION=${FABRIC_VERSION} .
set +x