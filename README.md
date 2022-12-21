## Note: new approach for node deployment:
Copy `org_env_sample` to `<org_name>_env` (e.g. `org1_env`) and adjust properties.
Run 
```bash
./deploy.sh org1
```  



# Starter Application for Hyperledger Fabric

*(!) The project has switched to Hyperledger Fabric v2.3. For using previous versions see **snapshot-xxx** branches*

Create a Hyperledger Fabric network to jump start development of your decentralized application on 
[Hyperledger Fabric](https://www.hyperledger.org/projects/fabric) platform.

The network is run by docker containers and can be deployed to one host for development or to multiple hosts for testing 
or production.

Scripts of this starter generate crypto material and config files, start the Hyperledger Fabric node and deploy your chaincodes.
Additional nodes can be started and automatically connected to a Blockchain network.


Developers can use [REST API](https://github.com/olegabu/fabric-starter-rest) to invoke and query chaincodes, 
explore blocks and transactions.

What's left is to develop your chaincodes and place them into the [chaincode](./chaincode) folder, 
and user interface as a single page web app that you can serve by by placing the sources into the [www](./www) folder.

See also

- [fabric-starter-rest](https://github.com/olegabu/fabric-starter-rest) REST API server and client built with NodeJS SDK
- [fabric-starter-web](https://github.com/olegabu/fabric-starter-web) Starter web application to work with the REST API
- [chaincode-node-storage](https://github.com/olegabu/chaincode-node-storage) Base class for node.js chaincodes with CRUD functionality


## Blockchain network deployment

The following sections describe Fabric Starter possibilities in more details:

- [Prerequisites](#install)
- [Network with one organization (and orderer) for development](#example1org)
- [Adding other organizations to the Network](#addorgs)
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
## Create a network with one organization
See [Start an organization node](docs/network-node-start.md)


<a name="addorgs"></a>
## Add other organizations to the Network
See [Add organizations to Network](docs/network-add-orgs.md)


<a name="restapi"></a>
## Use REST API to query and invoke chaincodes
See [Use REST Api](docs/rest-api.md)


<a name="ldapauth"></a>
## Use LDAP for user authentication and management


LDAP and Hyperledger Fabric Certification Authority are the two options for user management and membership. 
See [Use LDAP](docs/ldap.md) for LDAP details.


<a name="consensus-types"></a>
## Consensus Types. RAFT consensus algorithm.


Two types of consensus are used for ordering: Raft and Solo. For using Raft consensus see
instructions in [Start Raft Ordering Service](docs/raft.md)

<a name="chaincode-packages"></a>
## Prepare and install chaincodes

See [Install Chaincodes](docs/chaincodes.md)


<a name="releasecycle"></a>
## Releases\Snapshots cycle 

When the code is stable for release or before introducing major changes\new features the branches 
`stable`, `hlf-{fabric-version}-stable` and `hlf-{fabric-version}-snapshot-{version}` are created.

Up to the snapshot-0.13-2.3 the `snapshot-{version}-{fabric-version}` tempate was used. 


`Note`, the Hyperledger Fabric version and the Fabric Starter version which the snapshot 
depends on are defined in the `.env` file.  
