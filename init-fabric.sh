#!/usr/bin/env bash

# adjust ---------------
: ${FABRIC_VERSION:="1.1.0-rc1"}
#-----------------------
FABRIC_PACK="x86_64-${FABRIC_VERSION}"

#if [ ! -f 'bin/configtxgen' ]; then
#  ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')
#  sudo echo
#  url=https://nexus.hyperledger.org/content/repositories/releases/org/hyperledger/fabric/hyperledger-fabric/${ARCH}-${FABRIC_VERSION}/hyperledger-fabric-${ARCH}-${FABRIC_VERSION}.tar.gz
#  echo "===> Downloading platform binaries: $url"
#  curl $url | tar xz
#fi;

sudo apt-get update && sudo apt-get -y install docker-compose jq

sudo docker rmi -f $(docker images -q)

sudo docker pull hyperledger/fabric-ca:${FABRIC_PACK}
sudo docker pull hyperledger/fabric-orderer:${FABRIC_PACK}
sudo docker pull hyperledger/fabric-peer:${FABRIC_PACK}
sudo docker pull hyperledger/fabric-ccenv:${FABRIC_PACK}
#docker pull hyperledger/fabric-buildenv:${FABRIC_PACK}

sudo docker pull hyperledger/fabric-tools:${FABRIC_PACK}
#workaround until fixed in 1.1.0-alpha
sudo docker pull hyperledger/fabric-tools:x86_64-1.1.0-preview

sudo docker pull hyperledger/fabric-baseos:x86_64-0.4.5
sudo docker pull hyperledger/fabric-baseos:x86_64-0.4.6
sudo docker pull maxxx1313/fabric-rest
sudo docker pull nginx
sudo docker pull node:6-alpine
export FABRIC_PACK

echo
echo "---------------------------------"
echo "Relogin to apply the user into the 'docker' group"
echo "---------------------------------"



