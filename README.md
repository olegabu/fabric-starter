# Starter Application for Hyperledger Fabric

Create a network to jump start development of your decentralized application.

The network can be deployed to multiple docker containers on one host for development or to multiple hosts for testing 
or production.

Scripts of this starter generate crypto material and config files, start the network and deploy your chaincodes. 
Developers can use REST API to invoke and query chaincodes, explore blocks and transactions.

What's left is to develop your chaincodes and place them into the [chaincode](./chaincode) folder, 
and user interface as a single page web app that you can serve by by placing the sources into the [www](./www) folder. 

Most of the plumbing work is taken care of by this starter.

# Install

Install prerequisites: `docker`. This example is for Ubuntu 18:
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

# Build Fabric with Java support

Clean up. Delete all docker containers and images.
```bash
docker rm -f `(docker ps -aq)`
docker rmi -f `(docker images -aq)`
```

Create directories, environment and clone the latest source of Hyperledger Fabric from `master`.
```bash
mkdir -p ~/go
export GOPATH=~/go
mkdir -p $GOPATH/src/github.com/hyperledger
cd $GOPATH/src/github.com/hyperledger
git clone https://github.com/hyperledger/fabric
cd fabric
```

Build docker images with java enabled via `EXPERIMENTAL` flag.
```bash
export EXPERIMENTAL=true
make docker
```

Clone the latest source of java chaincode support.
```bash
cd $GOPATH/src/github.com/hyperledger
git clone https://github.com/hyperledger/fabric-chaincode-java 
cd fabric-chaincode-java
```

Build docker image for java chaincode `fabric-javaenv` and java `shim` for chaincode development.
```bash
./gradlew buildImage
./gradlew publishToMavenLocal
```

# Create a network with 1 organization for development

Generate crypto material and the genesis block for the *Orderer* organization. Using default *example.com* DOMAIN. 
```bash
./generate-orderer.sh
```

Start docker containers for *Orderer*.
```bash
docker-compose -f docker-compose/docker-compose-orderer.yaml up
```

Open another console. Generate crypto material for the member organization. Using default ORG name *org1*.
```bash
./generate-peer.sh
```

Start docker containers for *org1*.
```bash
docker-compose -f docker-compose/docker-compose-peer.yaml up
```

Open another console. Add *org1* to the consortium as *Admin* of the *Orderer* organization:
```bash
./consortium-addorg.sh org1
``` 

Create channel *common* as *Admin* of *org1* and join our peers to the channel:
```bash
./channel-create.sh common
./channel-join.sh common
``` 

Install and instantiate *java* chaincode *fabric-chaincode-example-gradle* on channel *common*. 
Note the path to the source code is inside `cli` docker container and is mapped to the local 
`./chaincode/java/fabric-chaincode-example-gradle`
```bash
./chaincode-install.sh fabric-chaincode-example-gradle /opt/chaincode/java/fabric-chaincode-example-gradle java 1.0
./chaincode-instantiate.sh common fabric-chaincode-example-gradle '["init","a","10","b","0"]'
```

Invoke chaincode *fabric-chaincode-example-gradle*.
```bash
./chaincode-invoke.sh common fabric-chaincode-example-gradle '["invoke","a","b","1"]'
```
Query chaincode.
```bash
./chaincode-query.sh common fabric-chaincode-example-gradle '["query","a"]'
```

# Example with a network of 3 organizations

You can replace default DOMAIN *example.com* and *org1*, *org2* with the names of your organizations.
Extend this example by adding more than 3 organizations and any number of channels with various membership.

## Create organizations and add them to the consortium

Clean up. Remove all containers, delete local crypto material:
```bash
./clean.sh
```

Generate and start the *orderer*:
```bash
./generate-orderer.sh
docker-compose -f docker-compose/docker-compose-orderer.yaml up
```

Generate and start *org1* in another console:
```bash
export ORG=org1 DOMAIN=example.com CRYPTO_CONFIG_DIR=./crypto-config 
export ORGS='{"org1":"peer0.org1.example.com:7051","org2":"peer0.org2.example.com:7051","org3":"peer0.org3.example.com:7051"}' CAS='{"org1":"ca.org1.example.com:7054"}'
./generate-peer.sh
docker-compose -f docker-compose/docker-compose-peer.yaml up
```

Generate and start *org2* in another console. Note the ports open to host machine need to be redefined to avoid collision:
```bash
export COMPOSE_PROJECT_NAME=org2 ORG=org2 DOMAIN=example.com CRYPTO_CONFIG_DIR=./crypto-config 
export ORGS='{"org1":"peer0.org1.example.com:7051","org2":"peer0.org2.example.com:7051","org3":"peer0.org3.example.com:7051"}' CAS='{"org2":"ca.org2.example.com:7054"}'
export CA_PORT=8054 PEER0_PORT=8051 PEER0_EVENT_PORT=8053 PEER1_PORT=8056 PEER1_EVENT_PORT=8058 API_PORT=3001 WWW_PORT=8082
./generate-peer.sh
docker-compose -f docker-compose/docker-compose-peer.yaml up
```

Generate and start *org3* in another console:
```bash
export COMPOSE_PROJECT_NAME=org3 ORG=org3 DOMAIN=example.com CRYPTO_CONFIG_DIR=./crypto-config 
export ORGS='{"org1":"peer0.org1.example.com:7051","org2":"peer0.org2.example.com:7051","org3":"peer0.org3.example.com:7051"}' CAS='{"org3":"ca.org2.example.com:7054"}'
export CA_PORT=9054 PEER0_PORT=9051 PEER0_EVENT_PORT=9053 PEER1_PORT=9056 PEER1_EVENT_PORT=9058 API_PORT=3002 WWW_PORT=8083
./generate-peer.sh
docker-compose -f docker-compose/docker-compose-peer.yaml up
```

Now you should have 4 console windows open running with the orderer, org1, org2, org3.

Open another console where we'll become the Admin of the *Orderer* organization. We'll add orgs to the consortium:
```bash
export DOMAIN=example.com
./consortium-addorg.sh org1
./consortium-addorg.sh org2
./consortium-addorg.sh org3
``` 

Now all 3 orgs are known in the consortium and all can create and join channels.

## Create channels, install and instantiate chaincodes

Open another console where we'll become *org1* again. We'll create channel *common*, add other orgs to it, 
and join our peers to the channel:
```bash
export ORG=org1 DOMAIN=example.com
./channel-create.sh common
./channel-add-org.sh org2 common
./channel-add-org.sh org3 common
./channel-join.sh common
``` 

Let's create a bilateral channel between *org1* and *org2* and join to it:
```bash
./channel-create.sh org1-org2
./channel-add-org.sh org2 org1-org2
./channel-join.sh org1-org2
```

Install and instantiate chaincode *reference* on channel *common*. Note the path to the source code is inside `cli` 
docker container and is mapped to the local  `./chaincode/node/reference`
```bash
./chaincode-install.sh reference /opt/chaincode/node/reference node 1.0
./chaincode-instantiate.sh common reference '["init","a","10","b","0"]'
```

Install and instantiate chaincode *relationship* on channel *org1-org2*:
```bash
./chaincode-install.sh relationship /opt/chaincode/node/relationship node 1.0
./chaincode-instantiate.sh org1-org2 relationship '["init","a","10","b","0"]'
```

Open another console where we'll become *org2* to install chaincodes *reference* and  *relationship* 
and to join channels *common* and *org1-org2*:
```bash
export COMPOSE_PROJECT_NAME=org2 ORG=org2 DOMAIN=example.com
./chaincode-install.sh reference /opt/chaincode/node/reference node 1.0
./chaincode-install.sh relationship /opt/chaincode/node/relationship node 1.0
./channel-join.sh common
./channel-join.sh org1-org2
``` 

Now become *org3* to install chaincode *reference* and join channel *common*:
```bash
export COMPOSE_PROJECT_NAME=org3 ORG=org3 DOMAIN=example.com
./chaincode-install.sh reference /opt/chaincode/node/reference node 1.0
./channel-join.sh common
``` 

## Use REST API servers to query and invoke chaincodes

Login into *org1* as *user1* and save returned token into env variable `JWT` which we'll use to identify our user 
in subsequent requests:
```bash
JWT=`(curl -d '{"login":"user1","password":"pass"}' --header "Content-Type: application/json" http://localhost:3000/users | tr -d '"')`
```

Query channels *org1* has joined
```bash
curl -H "Authorization: Bearer $JWT" http://localhost:3000/channels
```
returns
```json
[{"channel_id":"common"},{"channel_id":"org1-org2"}]
``` 

Query status, orgs, instantiated chaincodes and block 2 of channel *common*:
```bash
curl -H "Authorization: Bearer $JWT" http://localhost:3000/channels/common
curl -H "Authorization: Bearer $JWT" http://localhost:3000/channels/common/chaincodes
curl -H "Authorization: Bearer $JWT" http://localhost:3000/channels/common/orgs
curl -H "Authorization: Bearer $JWT" http://localhost:3000/channels/common/blocks/2
```

Invoke chaincode *reference* on channel *common*, it's implemented by chaincode_example_02 and moves 1 from a to b:
```bash
curl -H "Authorization: Bearer $JWT" --header "Content-Type: application/json" \
http://localhost:3000/channels/common/chaincodes/reference -d '{"fcn":"invoke","args":["a","b","1"]}'
```

Query chaincode *reference* on channel *common* for balances of a and b:
```bash
curl -H "Authorization: Bearer $JWT" --header "Content-Type: application/json" \
'http://localhost:3000/channels/common/chaincodes/reference?fcn=query&args=a'
```

Now login into the API server of *org2* `http://localhost:3001` and query balance of b:
```bash
JWT=`(curl -d '{"login":"user1","password":"pass"}' --header "Content-Type: application/json" http://localhost:3001/users | tr -d '"')`
curl -H "Authorization: Bearer $JWT" --header "Content-Type: application/json" \
'http://localhost:3001/channels/common/chaincodes/reference?fcn=query&args=b'
```
