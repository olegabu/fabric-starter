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
When running on local machine:
```bash
export API_PORT=4001 WWW_PORT=8082 CA_PORT=8054 PEER0_PORT=8051 PEER0_EVENT_PORT=8053 PEER1_PORT=8056 PEER1_EVENT_PORT=8058
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
http://localhost:4000/channels/common/chaincodes/reference -d '{"fcn":"put","args":["account","1","{name:\"one\"}"],"targets":["peer0.org2.example.com","peer1.org2.example.com:7051"]}'
```

Query function `list` of chaincode *reference* on channel *common* with args `["account"]` and `["targets"]`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
'http://localhost:4000/channels/common/chaincodes/reference?channelId=common&chaincodeId=reference&fcn=list&args=%5B%22account%22%5D&targets=%5B%22peer0.org2.example.com%22%2C%22peer1.org2.example.com%3A7051%22%5D'
```

# Multi host deployment with docker-machine and VirtualBox

Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) 
and [docker-machine](https://docs.docker.com/machine/get-started/).

## Create orderer machine

Create and start `orderer` docker host as a virtual machine.
For AWS EC2 use `--driver amazonec2` and `export WORK_DIR=/home/ubuntu`.
```bash
docker-machine create --driver virtualbox orderer
```

See the ip address of the created VM.
```bash
docker-machine ls
```
Returns
```
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER        ERRORS
orderer   *        virtualbox   Running   tcp://192.168.99.100:2376           v18.06.1-ce 
```

Connect to `orderer` machine by setting env variables.
```bash
eval "$(docker-machine env orderer)"
```

Start docker swarm on `orderer` machine. Replace ip address `192.168.99.100` with the actual ip of the remote host interface.
```bash
docker swarm init --advertise-addr 192.168.99.100
```
will output a command to join the swarm by other hosts; this is an example, use the actual token and ip.  
```bash
docker swarm join --token SWMTKN-1-4fbasgnyfz5uqhybbesr9gbhg0lqlcj5luotclhij87owzd4ve-4k16civlmj3hfz1q715csr8lf 192.168.99.100:2377
```

Copy local template files to `orderer` home directory (`/home/docker` on VirtualBox or `/home/ubuntu` on AWS EC2).
```bash
docker-machine scp -r templates orderer:templates
```

Now template files are on the `orderer` host and we can run `./generate-orderer.sh` but with a flag 
`COMPOSE_FLAGS` which adds an extra docker-compose file `orderer-multihost.yaml` on top of the base 
`docker-compose-orderer.yaml`. This file redefines volume mappings from `${PWD}` local to your host machine to 
directory on remote host specified by `WORK_DIR` (defaulted to VirtualBox's home `/home/docker`; 
for AWS EC2 do `export WORK_DIR=/home/ubuntu`).

```bash
./generate-orderer.sh
``` 

Start *Orderer* containers on `orderer` machine.
```bash
docker-compose -f docker-compose-orderer.yaml -f orderer-multihost.yaml up -d
```

## Create org1 machine

Create and start `org1` docker host as a virtual machine with VirtualBox. 
```bash
docker-machine create --driver virtualbox org1
```

Connect to `org1` machine by setting env variables.
```bash
eval "$(docker-machine env org1)"
```

Join swarm; this is an example, use the actual command output by `orderer`. In orderer console get the command:
```bash
docker swarm join-token worker
```
Execute the output command in `org1` console.
```bash
docker swarm join --token SWMTKN-1-4rzq6pyg3z2kw7eqhqdnc86isjpwo6t69t1q0ooy84csioieyc-ajcb0rdg3l15ronhytmldc59s 192.168.99.100:2377
```

Need to run a dummy container on this new host `org1` to force join overlay network `fabric-overlay` 
created by docker-compose on `orderer` host. 
```bash
docker run -dit --name alpine --network fabric-overlay alpine
```

Copy local template and chaincode files to `org1` machine.
```bash
docker-machine scp -r templates org1:templates

docker-machine scp -r chaincode org1:chaincode

docker-machine scp -r webapp org1:webapp
```

Generate crypto material for member organization *org1*.

```bash
./generate-peer.sh
``` 

Start *org1* containers on `org1` machine.
```bash
docker-compose -f docker-compose.yaml -f multihost.yaml up -d
``` 

## Add org1 to the consortium as Orderer

Now `org1` machine is up and running a web container serving root certificates of *org1*. The orderer can access it
via an overlay network, download certs and add *org1*.

Connect to `orderer` machine by setting env variables. Run local script to add to the consortium.
```bash
eval "$(docker-machine env orderer)"

./consortium-add-org.sh org1
```

## Create a channel and deploy chaincode as org1

Connect to `org1` machine by setting env variables. Run local scripts to create and join channels.
```bash
eval "$(docker-machine env org1)"

./channel-create.sh common

./channel-join.sh common

./chaincode-install.sh reference

./chaincode-instantiate.sh common reference 
```

## Create org2 machine

```bash
export ORG=org2
export ORGS='{"org1":"peer0.org1.example.com:7051","org2":"peer0.org2.example.com:7051"}' CAS='{"org2":"ca.org2.example.com:7054"}'
docker-machine create --driver virtualbox org2
eval "$(docker-machine env org2)"
docker swarm join --token SWMTKN-1-4fbasgnyfz5uqhybbesr9gbhg0lqlcj5luotclhij87owzd4ve-4k16civlmj3hfz1q715csr8lf 192.168.99.102:2377
docker run -dit --name alpine --network fabric-overlay alpine
docker-machine scp -r templates org2:templates
docker-machine scp -r chaincode org2:chaincode
./generate-peer.sh
docker-compose -f docker-compose.yaml -f multihost.yaml up
```

Move to `org1` machine to add *org2* to the channel.
```bash
eval "$(docker-machine env org1)"
./channel-add-org.sh common org2 
```

Back to `org2` machine to join channel.
```bash
export ORG=org2
eval "$(docker-machine env org2)"
./channel-join.sh common
```

Install chaincode (no need to instantiate) and query.
```bash
./chaincode-install.sh reference
./chaincode-query.sh common reference '["list","account"]'
```

## Create machines for other organizations

The above steps are collected into a single script that creates a machine, generates crypto material and starts 
containers on a remote or virtual host for a new org. This example is for *org3*; replace swarm token and manager ip 
with your own from `docker swarm join-token worker`.
```bash
./machine-create-peer.sh SWMTKN-1-4fbasgnyfz5uqhybbesr9gbhg0lqlcj5luotclhij87owzd4ve-4k16civlmj3hfz1q715csr8lf 192.168.99.102 org3
```

# LDAP Configuration

See [ldap.md](ldap.md)
