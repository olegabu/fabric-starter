#!/usr/bin/env bash

 DOMAIN=example.com
 ORG1=org1
 ORG2=org2
 CHANNEL_NAME=mychannel

#DOMAIN=nsd.ru
#ORG1=nsd
#ORG2=issuer
#CHANNEL_NAME=nsd-issuer

CLI_TIMEOUT=10000
COMPOSE_FILE=ledger/docker-compose.yaml
COMPOSE_TEMPLATE=ledger/docker-compose-template.yaml

# Delete any images that were generated as a part of this setup
# specifically the following images are often left behind:
# TODO list generated image naming patterns
function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
  if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" == " " ]; then
    echo "No images available for deletion"
  else
    echo "Removing docker images: $DOCKER_IMAGE_IDS"
    docker rmi -f $DOCKER_IMAGE_IDS
  fi
}

function removeArtifacts() {
  echo "Removing generated artifacts"
  rm -rf artifacts/crypto-config
  rm -rf artifacts/channel
}

function removeDockers() {
  if [ -f $COMPOSE_FILE ]; then
    echo "Removing docker containers"
    docker-compose -f $COMPOSE_FILE kill
    docker-compose -f $COMPOSE_FILE rm -f
  else
    echo "No generated docker-compose.yaml and no docker instances to remove"
  fi;
}

function generateArtifacts() {
    echo "Creating yaml files with names $DOMAIN, $ORG1, $ORG2"
    # configtx and cryptogen
    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" artifacts/configtxtemplate.yaml > artifacts/configtx.yaml
    sed -e "s/DOMAIN/$DOMAIN/g" artifacts/cryptogentemplate-orderer.yaml > artifacts/"cryptogen-$DOMAIN.yaml"
    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$ORG1/g" artifacts/cryptogentemplate-peer.yaml > artifacts/"cryptogen-$ORG1.yaml"
    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG/$ORG2/g" artifacts/cryptogentemplate-peer.yaml > artifacts/"cryptogen-$ORG2.yaml"
    # docker-compose.yaml
    sed -e "s/DOMAIN/$DOMAIN/g" -e "s/ORG1/$ORG1/g" -e "s/ORG2/$ORG2/g" -e "s/CHANNEL_NAME/$CHANNEL_NAME/g" $COMPOSE_TEMPLATE > $COMPOSE_FILE
    # network-config.json
    #  fill environments                                                   |   remove comments
    sed -e "s/\DOMAIN/$DOMAIN/g" -e "s/\ORG1/$ORG1/g" -e "s/\ORG2/$ORG2/g" -e "s/^\s*\/\/.*$//g" artifacts/network-config-template.json > artifacts/network-config.json
    sed -e "s/\DOMAIN/$DOMAIN/g" -e "s/\ORG1/$ORG1/g" -e "s/\ORG2/$ORG2/g" -e "s/^\s*\/\/.*$//g" artifacts-dev/network-config-template.json > artifacts-dev/network-config.json
    # fabric-ca-server-config.yaml
    sed -e "s/ORG/$ORG1/g" artifacts/fabric-ca-server-configtemplate.yaml > artifacts/"fabric-ca-server-config-$ORG1.yaml"
    sed -e "s/ORG/$ORG2/g" artifacts/fabric-ca-server-configtemplate.yaml > artifacts/"fabric-ca-server-config-$ORG2.yaml"

    echo "Generating crypto material with cryptogen"
    docker-compose --file $COMPOSE_FILE run --rm "cli.$DOMAIN" bash -c "cryptogen generate --config=cryptogen-$DOMAIN.yaml"
    docker-compose --file $COMPOSE_FILE run --rm "cli.$DOMAIN" bash -c "cryptogen generate --config=cryptogen-$ORG1.yaml"
    docker-compose --file $COMPOSE_FILE run --rm "cli.$DOMAIN" bash -c "cryptogen generate --config=cryptogen-$ORG2.yaml"

    echo "Generating orderer genesis block and channel config transaction with configtxgen"
    mkdir -p artifacts/channel
    docker-compose --file $COMPOSE_FILE run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel/genesis.block
    docker-compose --file $COMPOSE_FILE run --rm -e FABRIC_CFG_PATH=/etc/hyperledger/artifacts "cli.$DOMAIN" configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel/"$CHANNEL_NAME".tx -channelID "$CHANNEL_NAME"

    echo "Adding generated CA private keys filenames to yaml"
    CA1_PRIVATE_KEY=$(basename `ls artifacts/crypto-config/peerOrganizations/"$ORG1.$DOMAIN"/ca/*_sk`)
    CA2_PRIVATE_KEY=$(basename `ls artifacts/crypto-config/peerOrganizations/"$ORG2.$DOMAIN"/ca/*_sk`)
    [[ -z  $CA1_PRIVATE_KEY  ]] && echo "empty CA1 private key" && exit 1
    [[ -z  $CA2_PRIVATE_KEY  ]] && echo "empty CA2 private key" && exit 1
    sed -i -e "s/CA1_PRIVATE_KEY/${CA1_PRIVATE_KEY}/g" -e "s/CA2_PRIVATE_KEY/${CA2_PRIVATE_KEY}/g" $COMPOSE_FILE

    # docker generates files to mapped volumes as root, change ownership
    chown -R 1000:1000 artifacts/
}

function networkUp () {
  # generate artifacts if they don't exist
#  if [ ! -d "artifacts/crypto-config" ]; then
#    generateArtifacts
#  fi
  TIMEOUT=$CLI_TIMEOUT docker-compose -f $COMPOSE_FILE up -d 2>&1
  if [ $? -ne 0 ]; then
    echo "ERROR !!!! Unable to start network"
    sleep 5
    logs
    exit 1
  fi
  logs
}

function logs () {
    TIMEOUT=$CLI_TIMEOUT COMPOSE_HTTP_TIMEOUT=$CLI_TIMEOUT docker-compose -f $COMPOSE_FILE logs -f
}

function networkDown () {
  docker-compose -f $COMPOSE_FILE down
  # Don't remove containers, images, etc if restarting
  if [ "$MODE" != "restart" ]; then
    clean
  fi
}

function clean() {
  removeDockers
  removeUnwantedImages
}

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  network.sh -m up|down|restart|generate"
  echo "  network.sh -h|--help (print this message)"
  echo "    -m <mode> - one of 'up', 'down', 'restart' or 'generate'"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'restart' - restart the network"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'logs' - print and follow all docker instances log files"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	sudo network.sh -m generate"
  echo "	network.sh -m up"
  echo "	network.sh -m down"
}

# Parse commandline args
while getopts "h?m:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    m)  MODE=$OPTARG
    ;;
  esac
done

if [ "${MODE}" == "up" ]; then
  networkUp
elif [ "${MODE}" == "down" ]; then
  networkDown
elif [ "${MODE}" == "clean" ]; then
  clean
elif [ "${MODE}" == "generate" ]; then
  clean
  removeArtifacts
  generateArtifacts
elif [ "${MODE}" == "restart" ]; then
  networkDown
  networkUp
elif [ "${MODE}" == "logs" ]; then
  logs
else
  printHelp
  exit 1
fi
