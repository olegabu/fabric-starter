# Create a network with 1 organization for development

## Generate and start orderer

Generate crypto material and the genesis block for the *orderer* organization. Using default *example.com* DOMAIN. 
```bash
./generate-orderer.sh
```

Start docker containers for *orderer*.
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

Open another console. Add *org1* to the consortium as *Admin* of the *orderer* organization:
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
Note the path to the source code is inside `cli` docker container and is mapped to the local folder 
[./chaincode/node/reference](./chaincode/node/reference). 
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

./chaincode-upgrade.sh common reference [] 1.1
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
