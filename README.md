# Starter Application for Hyperledger Fabric 1.*

Create a network to jump start development of your decentralized application.

The network can be deployed to multiple docker containers on one host for development or to multiple hosts for testing 
or production.

Scripts of this starter generate crypto material and config files, start the network and deploy your chaincodes. 
Developers can use admin web app of 
[REST API server](https://github.com/maxxx1313/fabric-rest/tree/master/server/www-admin) 
to invoke and query chaincodes, explore blocks and transactions.

What's left is to develop your chaincodes and place them into the [chaincode](./chaincode) folder, 
and user interface as a single page web app that you can serve by by placing the sources into the [www](./www) folder. 
You can take web app code or follow patterns of the 
[admin app](https://github.com/maxxx1313/fabric-rest/tree/master/server/www-admin) to enroll users, 
invoke chaincodes and subscribe to events.

Most of the plumbing work is taken care of by this starter.

# Install

Install prerequisites: docker. This example is for Ubuntu 18:
```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install docker-ce docker-compose
# add yourself to the docker group and re-login
sudo usermod -aG docker ${USER}
```

# Create the network

## Orderer Organization

Define your project's DOMAIN: all of your component names will have this as a top level domain:
```bash
export DOMAIN=example.com
```

Run script on your host machine to generate crypto material and genesis block for the Orderer organization:
```bash
./generate-orderer.sh
```

Inspect how environment variables fill in values for docker parameters (optional):
```bash
docker-compose -f docker-compose/docker-compose-orderer.yaml config
```

Start the orderer
```bash
docker-compose -f docker-compose/docker-compose-orderer.yaml up
```

## Peer Organization 1

Open a separate console to allow for different environment variables and log output.

Define your project's DOMAIN and ORG, all other values will remain at defaults. COMPOSE_PROJECT_NAME needs to be redefined
since we may be reusing service names.
```bash
export DOMAIN=example.com ORG=org1 COMPOSE_PROJECT_NAME="$ORG"
```

Generate crypto material for peer organization org1:
```bash
./generate-peer.sh
```

Start docker containers for org1
```bash
docker-compose -f docker-compose/docker-compose-peer.yaml up
```
## Peer Organization 2

Open a separate console.

Define your project's DOMAIN and ORG, and override defaults ports as these containers expose them to the same host as org1:
```bash
export DOMAIN=example.com ORG=org2 COMPOSE_PROJECT_NAME=org2 PEER0_PORT=8051 PEER0_EVENT_PORT=8053 PEER1_PORT=8056 PEER1_EVENT_PORT=8058 API_PORT=4001 WWW_PORT=8082
```

Generate crypto material for peer organization org2:
```bash
./generate-peer.sh
```

Inspect how environment variables fill in values for docker parameters (optional):
```bash
docker-compose -f docker-compose/docker-compose-peer.yaml config
```

Start docker containers for org2
```bash
docker-compose -f docker-compose/docker-compose-peer.yaml up
```