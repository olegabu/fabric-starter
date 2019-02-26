# Starter Application for Hyperledger Fabric

Create a network to jump start development of your decentralized application on 
[Hyperledger Fabric](https://www.hyperledger.org/projects/fabric) platform.

The network is run by docker containers and can be deployed to one host for development or to multiple hosts for testing 
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


## Blockchain network deployment

The following sections describe Fabric Starter possibilites in more details:

- [Installation.](#install)
- [Network with 1 organization (and orderer) for development.](#example1org)
- [Several organizations on one (local) host in multiple docker containers.](#example3org)
- [REST API to query and invoke chaincodes.](#restapi)
- [Getting closer to production. Multiple hosts deployment with `docker-machine`. Deployment to clouds.](#multihost)
- [Development\Release cycle](#releasecycle)



<a name="install"></a>
## Install
See [Installation](docs/install.md)



<a name="setversion"></a>
## Using a particular version of Hyperledger Fabric
To deploy network with a particular version of HL Fabric export desired version in the 
FABRIC_VERSION environment variable. The `latest` docker image tag is used by default.
```bash
export FABRIC_VERSION=1.2.0
```


<a name="example1org"></a>
## Create a network with 1 organization for development
See [One Org Network](docs/network-one-org.md)



<a name="example3org"></a>
## Create a local network of 3 organizations
See [Three local Orgs Network](docs/network-three-org.md)


<a name="restapi"></a>
## Use REST API to query and invoke chaincodes
See [Use REST Api](docs/rest-api.md)

 <a name="multihost"></a>
## Multi host deployment
See [Multi host deployment](docs/multihost.md)


<a name="releasecycle"></a>
## Releases\Snapshots cycle

As this project doesn't have a defined release cycle yet we create 
`snapshot-{version}-{fabric-version}` branches  
when we see code is stable enough or before introducing major changes\new features.  

`Note`, the Hyperledger Fabric version which the snapshot depends on is defined in the `.env` file.  
Also this project uses _olegabu/fabric-starter-rest_ docker image which has 
the same versioning approach but even updated docker image with the same label (e.g. latest)
won't be pulled automatically if it exists in the local docker registry.   
You have to remove the old image manually (by `docker rmi -f olegabu/fabric-starter-rest`).    


The _`master`_ branch as well as potentially _`feature branches`_ are used for development.  
`Master` is assigned to the _`latest`_ version of Fabric.


#### Currently issued branches are:

- master(development)
- snapshot-0.3-1.4
    - use _fabric-starter-rest:snapshot-0.3-1.4_
- snapshot-0.2-1.4
    - use _fabric-starter-rest:snapshot-0.2-1.4_
- snapshot-0.1-1.4
    - start snapshot branching
