# Starter Application for Hyperledger Fabric

*(!) The project has switched to Hyperledger Fabric v2.3. For using previous versions see **snapshot-xxx** branches*

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

- [Prerequisites](#install)
- [Network with one organization (and orderer) for development](#example1org)
- [Adding other organizations to the Network](#example3org)
- [REST API to query and invoke chaincodes](#restapi)
- [Using LDAP for user authentication and management](#restapi)
- [Consensus Types. RAFT consensus algorithm](#consensus-types)
- [Prepare and install chaincode packages ](#chaincode-packages)
- [Development\Release cycle](#releasecycle)



<a name="install"></a>
## Install
See [Prerequisites](docs/install.md)



<a name="setversion"></a>
## Using a particular version of Hyperledger Fabric
By default Fabric starter uses the 2.3 version of HL Fabric. If you want to deploy network with another version of HL Fabric then export it in the 
FABRIC_VERSION environment variable, e.g.:
```bash
export FABRIC_VERSION=1.4.8
```


<a name="example1org"></a>
## Create a network with 1 organization for development
See [One Org Network](docs/network-one-org.md)



<a name="example3org"></a>
## Create a local network of 3 organizations
See [Three local Orgs Network](docs/network-add-orgs.md)


<a name="restapi"></a>
## Use REST API to query and invoke chaincodes
See [Use REST Api](docs/rest-api.md)


<a name="ldapauth"></a>
## Use LDAP for user authentication and management 
By default Hyperledger Fabric Certification Authority center is used to manage user management and membership. 
To use LDAP directory services see [Use LDAP](docs/ldap.md)


<a name="consensus-types"></a>
##Consensus Types. RAFT consensus algorithm.
By default Fabric Starter uses Solo type of consensus.
To use RAFT consensus see instructions in [Start Raft Ordering Service](docs/raft.md)

<a name="chaincode-packages"></a>
## Prepare and install chaincode packages

- Fabric 1.x:

Archive the chaincode directory:

```zip -r ${zipArchive} ./${chaincodeFolder}/*```

- Fabric 2.x:

  At first it's necessary to prepare install package in the `cli.peer` container:
  - copy source code  folder to `./chaincode` folder (as it's shared with the `cli` container)
  - prepare package:
      ```bash
    docker exec -t cli.peer0.${ORG}.${DOMAIN} peer lifecycle chaincode \
      package /opt/chaincode/${chaincodeName}.tar.gz --path /opt/chaincode/${chaincodeFolder} \
      --lang node --label ${chaincodeName}_1.0
      ```

In UI install the prepared package and instantiate the chaincode

<a name="releasecycle"></a>
## Releases\Snapshots cycle

As this project doesn't have a defined release cycle yet we create `stable`, 
`hlf-{fabric-version}-snapshot-{version}` and `hlf-{fabric-version}-stable`
branches when we see code is stable enough or before introducing major changes\new features.  
Before the snapshot version 14 we used the `snapshot-{version}-{fabric-version}` template for branch names. 

`Note`, the Hyperledger Fabric version and the Fabric Starter version which the snapshot 
depends on are defined in the `.env` file.  
Also this project uses _olegabu/fabric-starter-rest_ docker image which has 
the same versioning approach but even updated docker image with the same label (e.g. latest)
won't be pulled automatically if it exists in the local docker registry.   
You have to remove the old image manually (by `docker rmi -f olegabu/fabric-starter-rest`).    


The _`master`_ branch as well as potentially _`feature branches`_ are used for development.  
`Master` is assigned to the _`latest`_ version of Fabric. (discuss)


#### Currently issued branches are:

- master(development)
- snapshot-0.5-1.4
    - new org auto connect for invite type consortium
    - new orgs dns register functionality
    - use _fabric-starter-rest:snapshot-0.4-1.4_
- snapshot-0.4-1.4
    - auto-generate crypto configuration
    - Invite type consortium
    - BOOTSTRAP_IP for new node joining
- snapshot-0.3-1.4
    - use _fabric-starter-rest:snapshot-0.3-1.4_
- snapshot-0.2-1.4
    - use _fabric-starter-rest:snapshot-0.2-1.4_
- snapshot-0.1-1.4
    - start snapshot branching
