#!/usr/bin/env bash

DOMAIN=example.com
ORG1=org1
ORG2=org2
CHANNEL_NAME=mychannel

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# TODO list generated image naming patterns
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "No images available for deletion"
  else
    echo "Remove docker images: $DOCKER_IMAGE_IDS"
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

function removeArtifacts() {
  echo "Remove artifacts"
  rm -rf artifacts/crypto-config
  rm -rf artifacts/channel
}

function removeDockers() {
  if [ -f ledger/docker-compose.yaml ]; then
    echo "Remove docker containers"
    docker-compose -f ledger/docker-compose.yaml kill
    docker-compose -f ledger/docker-compose.yaml rm -f
  else
    echo "Docker containers is crear"
  fi;
}


removeDockers
sleep 10
removeUnwantedImages
removeArtifacts


# create crypto config
echo "Generate certificates"
sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" artifacts/configtxtemplate.yaml > artifacts/configtx.yaml
sed -e "s/DOMAIN/$DOMAIN/g" artifacts/cryptogentemplate-orderer.yaml > artifacts/"cryptogen-$DOMAIN.yaml"
sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$ORG1/g" artifacts/cryptogentemplate-peer.yaml > artifacts/"cryptogen-$ORG1.yaml"
sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$ORG2/g" artifacts/cryptogentemplate-peer.yaml > artifacts/"cryptogen-$ORG2.yaml"

mkdir -p artifacts/channel

# make docker-compose config (without CA_PRIVATE_KEY!)
sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" -e "s/CHANNEL_NAME/$CHANNEL_NAME/g" -e "s/CA1_PRIVATE_KEY/${CA1_PRIVATE_KEY}/g" -e "s/CA2_PRIVATE_KEY/${CA2_PRIVATE_KEY}/g" ledger/docker-compose-template.yaml > ledger/docker-compose.yaml

docker-compose --file ledger/docker-compose.yaml run --rm "cli.$DOMAIN" bash -c "cryptogen generate --config=cryptogen-$DOMAIN.yaml"
docker-compose --file ledger/docker-compose.yaml run --rm "cli.$DOMAIN" bash -c "cryptogen generate --config=cryptogen-$ORG1.yaml"
docker-compose --file ledger/docker-compose.yaml run --rm "cli.$DOMAIN" bash -c "cryptogen generate --config=cryptogen-$ORG2.yaml"
docker-compose --file ledger/docker-compose.yaml run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel/genesis.block
docker-compose --file ledger/docker-compose.yaml run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel/"$CHANNEL_NAME".tx -channelID "$CHANNEL_NAME"

CA1_PRIVATE_KEY=$(basename `ls artifacts/crypto-config/peerOrganizations/"$ORG1.$DOMAIN"/ca/*_sk`)
CA2_PRIVATE_KEY=$(basename `ls artifacts/crypto-config/peerOrganizations/"$ORG2.$DOMAIN"/ca/*_sk`)

[[ -z  $CA1_PRIVATE_KEY  ]] && echo "empty CA1 private key" && exit 1
[[ -z  $CA2_PRIVATE_KEY  ]] && echo "empty CA2 private key" && exit 1


# make docker-compose config (when certificate keys are generated)
echo "Generate launch configuration"
sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" -e "s/CHANNEL_NAME/$CHANNEL_NAME/g" -e "s/CA1_PRIVATE_KEY/${CA1_PRIVATE_KEY}/g" -e "s/CA2_PRIVATE_KEY/${CA2_PRIVATE_KEY}/g" ledger/docker-compose-template.yaml > ledger/docker-compose.yaml

sed -e "s/\$DOMAIN/$DOMAIN/g" -e "s/\$ORG1/$ORG1/g" -e "s/\$ORG2/$ORG2/g" artifacts/network-config-template.json > artifacts/network-config.json


# docker generates files to mapped volumes as root, change ownership
chown -R 1000:1000 artifacts/

echo Done! Use \"docker-compose -f ledger/docker-compose.yaml up\" to start
