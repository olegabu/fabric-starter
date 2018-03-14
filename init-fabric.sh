#!/usr/bin/env bash

# adjust ---------------
: ${FABRIC_VERSION:="1.1.0-rc1"}
#-----------------------

ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
FABRIC_PACK="x86_64-${FABRIC_VERSION}"

sudo apt-get update && sudo apt-get -y install docker-compose git jq enca


if [ ! -f 'bin/configtxgen' ]; then
  url=https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${FABRIC_VERSION}/hyperledger-fabric-${ARCH}-${FABRIC_VERSION}.tar.gz
  echo "===> Downloading platform binaries: $url"
  curl $url | tar xz
fi;

docker pull hyperledger/fabric-ca:${FABRIC_PACK}
docker pull hyperledger/fabric-orderer:${FABRIC_PACK}
docker pull hyperledger/fabric-peer:${FABRIC_PACK}
docker pull hyperledger/fabric-ccenv:${FABRIC_PACK}
#docker pull hyperledger/fabric-buildenv:${FABRIC_PACK}

docker pull hyperledger/fabric-tools:${FABRIC_PACK}
#workaround until fixed in 1.1.0-alpha
docker pull hyperledger/fabric-tools:x86_64-1.1.0-preview

docker pull hyperledger/fabric-baseos:x86_64-0.4.5
docker pull maxxx1313/fabric-rest
docker pull nginx
docker pull node:6-alpine
export FABRIC_PACK=x86_64-1.1.0-alpha


