# Starter Application for Hyperledger Fabric

Create a network to jump start development of your decentralized application on 
[Hyperledger Fabric](https://www.hyperledger.org/projects/fabric) platform.

The network can be deployed to multiple docker containers on one host for development or to multiple hosts for testing 
or production.

Scripts of this starter generate crypto material and config files, start the network and deploy your chaincodes. 
Developers can use [REST API](https://github.com/olegabu/fabric-starter-rest) to invoke and query chaincodes, 
explore blocks and transactions.

What's left is to develop your chaincodes and place them into the [chaincode](./chaincode) folder, 
and user interface as a single page web app that you can serve by by placing the sources into the [www](./www) folder.

See also

- [fabric-starter-rest](https://github.com/olegabu/fabric-starter-rest) REST API server and client built with NodeJS SDK
- [fabric-starter-web](https://github.com/olegabu/fabric-starter-web) Starter web application to work with the REST API
- [chaincode-node-storage](https://github.com/olegabu/chaincode-node-storage) Base class for node.js chaincodes with CRUD functionality

# Install

Install prerequisites: `docker >=18.06.1` and `docker-compose >=1.22.0`.

## Ubuntu 18

```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt-get install docker-ce

sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# add yourself to the docker group and re-login
sudo usermod -aG docker ${USER}
```

## Mac OSX

Install `docker ce` and `docker compose` by [brew](https://brew.sh/).
```bash
brew install docker 
```

## Using particular version of Hyperledger Fabric

To deploy network in a particular version of HL Fabric framework export desired version in the FABRIC_VERSION environment variable:
```bash
export FABRIC_VERSION=1.2.0
```

# Create a network with 1 organization for development

## Generate and start orderer

Generate crypto material and the genesis block for the *Orderer* organization. Using default *example.com* DOMAIN. 
```bash
./generate-orderer.sh
```

Start docker containers for *Orderer*.
```bash
docker-compose -f docker-compose-orderer.yaml up
```

## Generate and start member organization

Open another console. Generate crypto material for the member organization. Using default ORG name *org1*.
```bash
./generate-peer.sh
```

Start docker containers for *org1*.
```bash
docker-compose up
```

## Add organization to the consortium and create a channel

Open another console. Add *org1* to the consortium as *Admin* of the *Orderer* organization:
```bash
./consortium-add-org.sh org1
``` 

Create channel *common* as *Admin* of *org1* and join our peers to the channel:
```bash
./channel-create.sh common

./channel-join.sh common
``` 

## Install and instantiate chaincode

Install and instantiate *nodejs* chaincode *reference* on channel *common*. 
Using defaults: language `node`, version `1.0`, empty args `[]`.
Note the path to the source code is inside `cli` docker container and is mapped to the local 
`./chaincode/node/reference`. 
```bash
./chaincode-install.sh reference

./chaincode-instantiate.sh common reference
```

## Invoke chaincode

Chaincode *reference* extends [chaincode-node-storage](https://github.com/olegabu/chaincode-node-storage) 
which provides CRUD functionality.

Invoke chaincode to save entities of type *account*.
```bash
./chaincode-invoke.sh common reference '["put","account","1","{\"name\":\"one\"}"]'

./chaincode-invoke.sh common reference '["put","account","2","{\"name\":\"two\"}"]'
```

Query chaincode functions *list* and *get*.
```bash
./chaincode-query.sh common reference '["list","account"]'

./chaincode-query.sh common reference '["get","account","1"]'
```

## Upgrade chaincode 

Now you can make changes to your chaincode, install a new version `1.1` and upgrade to it.
```bash
./chaincode-install.sh reference 1.1

./chaincode-upgrade.sh common reference 1.1 []
```

When you develop and need to push your changes frequently, this shortcut script will install and instantiate with a 
new random version
```bash
./chaincode-reload.sh common reference
``` 

## Golang chaincode 

Install and instantiate *golang* chaincode *example02* on channel *common*. 
Source code is in local `./chaincode/go/chaincode_example02` mapped to `/opt/gopath/src/chaincode_example02` 
inside `cli` container.
```bash
./chaincode-install.sh example02 1.0 chaincode_example02 golang
./chaincode-instantiate.sh common example02 '["init","a","10","b","0"]'
./chaincode-invoke.sh common example02 '["move","a","b","1"]'
./chaincode-query.sh common example02 '["query","a"]'
```

Reload *golang* chaincode.
```bash
./chaincode-reload.sh common example02 '["init","a","10","b","0"]' chaincode_example02 golang
```

# Example with a network of 3 organizations

You can replace default DOMAIN *example.com* and *org1*, *org2* with the names of your organizations. 
Define them via environment variables either in shell or `.env` file. 
```bash
export DOMAIN=example.com ORG=org1
```

You can also extend this example by adding more than 3 organizations and any number of channels with various membership.

## Create organizations and add them to the consortium

Clean up. Remove all containers, delete local crypto material:
```bash
./clean.sh
```

Generate crypto material and start docker containers of the *Orderer* organization:
```bash
./generate-orderer.sh

docker-compose -f docker-compose-orderer.yaml up
```

Open another shell. Set environment variables `ORGS` and `CAS` that define how this org's client will connect to other 
organizations' peers and certificate authorities. When moving to multi host deployment they will be need 
to be redefined.

Generate and start *org1*.
```bash
export ORGS='{"org1":"peer0.org1.example.com:7051","org2":"peer0.org2.example.com:7051","org3":"peer0.org3.example.com:7051"}' CAS='{"org1":"ca.org1.example.com:7054"}'

./generate-peer.sh

docker-compose up
```

Open another shell. Note since we're reusing the same `docker-compose.yaml` file we need to redefine `COMPOSE_PROJECT_NAME`.
Also the ports open to host machine need to be redefined to avoid collision.

Generate and start *org2*.
```bash
export COMPOSE_PROJECT_NAME=org2 ORG=org2 
export ORGS='{"org1":"peer0.org1.example.com:7051","org2":"peer0.org2.example.com:7051","org3":"peer0.org3.example.com:7051"}' CAS='{"org2":"ca.org2.example.com:7054"}'
```
When running on local machine redefine the api port mapped to the host:
```bash
export API_PORT=4001
```

Then start the peer
```bash
./generate-peer.sh

docker-compose up
```

Generate and start *org3* in another shell:
```bash
export COMPOSE_PROJECT_NAME=org3 ORG=org3 
export ORGS='{"org1":"peer0.org1.example.com:7051","org2":"peer0.org2.example.com:7051","org3":"peer0.org3.example.com:7051"}' CAS='{"org3":"ca.org2.example.com:7054"}'
export API_PORT=4002

./generate-peer.sh

docker-compose up
```

Now you should have 4 console windows running containers of *Orderer*, *org1*, *org2*, *org3* organizations.

Open another console where we'll become an *Admin* user of the *Orderer* organization. We'll add orgs to the consortium:
```bash
./consortium-add-org.sh org1
./consortium-add-org.sh org2
./consortium-add-org.sh org3
``` 

Now all 3 orgs are known in the consortium and can create and join channels.

## Create channels, install and instantiate chaincodes

Open another console where we'll become *org1* again. We'll create channel *common*, add other orgs to it, 
and join our peers to the channel:
```bash
./channel-create.sh common
./channel-add-org.sh common org2 
./channel-add-org.sh common org3 
./channel-join.sh common
``` 

Let's create a bilateral channel between *org1* and *org2* and join to it:
```bash
./channel-create.sh org1-org2
./channel-add-org.sh org1-org2 org2 
./channel-join.sh org1-org2
```

Install and instantiate chaincode *reference* on channel *common*. Note the path to the source code is inside `cli` 
docker container and is mapped to the local  `./chaincode/node/reference`
```bash
./chaincode-install.sh reference
./chaincode-instantiate.sh common reference 
```

Install and instantiate chaincode *relationship* on channel *org1-org2*:
```bash
./chaincode-install.sh relationship
./chaincode-instantiate.sh org1-org2 relationship '["init","a","10","b","0"]'
```

Open another console where we'll become *org2* to install chaincodes *reference* and  *relationship* 
and to join channels *common* and *org1-org2*:
```bash
export COMPOSE_PROJECT_NAME=org2 ORG=org2

./chaincode-install.sh reference
./chaincode-install.sh relationship
./channel-join.sh common
./channel-join.sh org1-org2
``` 

Now become *org3* to install chaincode *reference* and join channel *common*:
```bash
export COMPOSE_PROJECT_NAME=org3 ORG=org3

./chaincode-install.sh reference
./channel-join.sh common
``` 

## Use REST API to query and invoke chaincodes

Login into *org1* as *user1* and save returned token into env variable `JWT` which we'll use to identify our user 
in subsequent requests:
```bash
JWT=`(curl -d '{"username":"user1","password":"pass"}' --header "Content-Type: application/json" http://localhost:4000/users | tr -d '"')`
```

Query channels *org1* has joined
```bash
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels
```
returns
```json
[{"channel_id":"common"},{"channel_id":"org1-org2"}]
``` 

Query status, orgs, instantiated chaincodes and block 2 of channel *common*:
```bash
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels/common
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels/common/chaincodes
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels/common/orgs
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels/common/blocks/2
```

Invoke function `put` of chaincode *reference* on channel *common* to save entity of type `account` and id `1`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
http://localhost:4000/channels/common/chaincodes/reference -d '{"fcn":"put","args":["account","1","{name:\"one\"}"]}'
```

Query function `list` of chaincode *reference* on channel *common* with args `["account"]`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
'http://localhost:4000/channels/common/chaincodes/reference?fcn=list&args=%5B%22account%22%5D'
```

# Multi host deployment with docker-machine

## Prerequisites

Install [docker-machine](https://docs.docker.com/machine/get-started/).
To run multiple (virtual) hosts on one dev machine install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

### Create host machines

Create 3 hosts: orderer and member organizations org1 and org2.
```bash
docker-machine create orderer
docker-machine create org1
docker-machine create org2
```

### Create orderer organization

Tell the scripts to use extra multihost docker-compose yaml files.
```bash
export MULTIHOST=true
```

Copy config templates to the orderer host.
```bash
docker-machine scp -r templates orderer:templates
```

Connect docker client to the orderer host. 
The docker commands that follow will be executed on the host not local machine.
```bash
eval "$(docker-machine env orderer)"
```

Inspect IPs of the hosts created and save them into env variables: `*_IP` will be used in `extra_hosts` sections in 
docker-compose yaml files and will eventually end up in containers' `/etc/hosts` to resolve other container names 
to remote IPs.
```bash
export ORDERER_IP=`(docker-machine ip orderer)` && export ORG1_IP=`(docker-machine ip org1)` && export ORG2_IP=`(docker-machine ip org2)`
```
Alternatively, edit `extra_hosts` in `multihost.yaml` and `orderer-multihost.yaml` to specify host IPs directly.

Generate crypto material for the orderer organization and start its docker containers.
```bash
./generate-orderer.sh
docker-compose -f docker-compose-orderer.yaml -f orderer-multihost.yaml up -d
```

### Create member organizations

Open a new console. Use env variables to tell the scripts to use multihost config yaml and to name your organization.
```bash
export MULTIHOST=true && export ORG=org1
```

Copy templates, chaincode and webapp folders to the host.
```bash
docker-machine scp -r templates $ORG:templates && docker-machine scp -r chaincode $ORG:chaincode && docker-machine scp -r webapp $ORG:webapp
```

Connect docker client to the organization host.
```bash
eval "$(docker-machine env $ORG)"
```

Save IPs of your hosts.
```bash
export ORDERER_IP=`(docker-machine ip orderer)` && export ORG1_IP=`(docker-machine ip org1)` && export ORG2_IP=`(docker-machine ip org2)`
```

Generate crypto material for the org and start its docker containers.
```bash
./generate-peer.sh
docker-compose -f docker-compose.yaml -f multihost.yaml up -d
```

To create other organizations repeat the above steps in separate consoles 
and giving them names by `export ORG=org2` in the first step.

### Add member organizations to the consortium

Return to the *orderer* console.

Now the member organizations are up and serving their certificates. 
The orderer host can download them to add to the consortium definition. 
```bash
./consortium-add-org.sh org1
./consortium-add-org.sh org2
```

### Create a channel and a chaincode

Return to the *org1* console.

The first organization creates channel *common*, joins to it and installs and instantiates chaincode *reference*.
```bash
./channel-create.sh common
./channel-join.sh common
./chaincode-install.sh reference
./chaincode-instantiate.sh common reference
```

Test the chaincode by invoke and query.
```bash
./chaincode-invoke.sh common reference '["put","account","1","{\"name\":\"one\"}"]'
./chaincode-query.sh common reference '["list","account"]'
```

Add other organizations to channel *common*.
```bash
 ./channel-add-org.sh common org2
```

### Have other organizations join the channel

Return to *org2* console.

Join *common* and install *reference*.
```bash
./channel-join.sh common
./chaincode-install.sh reference
``` 

Test the chaincode by a query by *org2*.
```bash
./chaincode-query.sh common reference '["list","account"]'
```
