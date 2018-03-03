#!/usr/bin/env bash

# adjust
: ${FABRIC_VERSION:="1.1.0-alpha"}
#-------

ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
FABRIC_PACK="x86_64-${FABRIC_VERSION}"

if [ ! -f 'bin/configtxgen' ]; then
  url=https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${FABRIC_VERSION}/hyperledger-fabric-${ARCH}-${FABRIC_VERSION}.tar.gz
  echo "===> Downloading platform binaries: $url"
  curl $url | tar xz
fi;

sudo apt-get update && sudo apt-get -y install docker-compose git jq enca


#git clone https://github.com/olegabu/nsd-commercial-paper
#cd nsd-commercial-paper
git clone https://github.com/olegabu/fabric-starter && cd fabric-starter
chmod +x *.sh


docker pull hyperledger/fabric-ca:${FABRIC_PACK}
docker pull hyperledger/fabric-orderer:${FABRIC_PACK}
docker pull hyperledger/fabric-peer:${FABRIC_PACK}
docker pull hyperledger/fabric-tools:${FABRIC_PACK}
docker pull hyperledger/fabric-tools:x86_64-1.1.0-preview
docker pull maxxx1313/fabric-rest
docker pull nginx
docker pull node:6-alpine


