FABRIC_VERSION=${1:-${FABRIC_VERSION:-latest}}
FABRIC_STARTER_VERSION=${2:-${FABRIC_STARTER_VERSION:-latest}}
set -x
cached=${3-"--no-cache"}
docker build -t olegabu/fabric-tools-extended:${FABRIC_STARTER_VERSION} -f ./fabric-tools-extended/Dockerfile ${cached} --build-arg FABRIC_VERSION=${FABRIC_VERSION} .
set +x