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

- [Prerequisites](#install)
- [Network with 1 organization (and orderer) for development](#example1org)
- [Several organizations on one (local) host in multiple docker containers.](#example3org)
- [REST API to query and invoke chaincodes.](#restapi)
- [Getting closer to production. Multiple hosts deployment with `docker-machine`. Deployment to clouds.](#multihost)
- [Join to an External Network](#joinexternal)
- [Network Governance. Invite-based and Majority-based Governance](#network-governance)
- [Consensus Types. RAFT consensus algorithm](#consensus-types)
- [Development\Release cycle](#releasecycle)



<a name="install"></a>
## Install
See [Prerequisites](docs/install.md)



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


<a name="joinexternal"></a>
## Join to an External Network
For `invite-based` blockchain-networks (see next chapter) new organization can be added to the consortium by a member of this network.
The new organization need to obtain the BOOTSRAP_IP (currently it's the IP of the _orderer_ node) and deploy its own node with this IP.  
```bash
export BOOTSTRAP_IP=192.168.0.1
#ORG=... DOMAIN=... docker-compose up
```
Then the new organization passes the ip address of the newly deployed node to the network's member and this member adds the organization to Consortium by it's administration dashboard.
After that the new organization can create own channels, add other organizations to the own channels and even invite more organizations to the network itself.     

<a name="network-governance"></a>
## Network Governance. Invite-based and Majority-based Governance

So now our network can be governed by itself (or to say it right by the network's members). 
The first type of network-governance is `Invite-based`. With this type of deployment 
any organization ((and not a central system administrator)) - member of the blockchain network can add new organization to consortium.

To deploy such type of network export environment variable
```bash
export CONSORTIUM_CONFIG=InviteConsortiumPolicy
```
Start orderer:
```bash
WWW_PORT=81 WORK_DIR=./ docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-multihost.yaml up -d
```

Then start an organization
```bash
MY_IP=192.168.99.yy BOOTSTRAP_IP=192.168.99.xx ORG=org1 MULTIHOST=true WORK_DIR=./ docker-compose -f docker-compose.yaml -f docker-compose-multihost.yaml -f docker-compose-api-port.yaml up -d 
```

`Majority` type of governance is coming.       


<a name="consensus-types"></a>
Consensus Types. RAFT consensus algorithm.
By default Fabric Starter uses Solo type of consensus.
To use RAFT consensus see instructions in [Start Raft Ordering Service](docs/raft.md)


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



MY_IP=192.168.99.102 FABRIC_STARTER_HOME=/home/docker dco -f docker-compose-remote-starter.yaml up --force-recreate
ORG=org2 FABRIC_STARTER_HOME=/home/docker AGENT_MODE=server-join BOOTSTRAP_IP=192.168.99.102 MY_IP=192.168.99.103 dco -f docker-compose-remote-starter.yaml up --force-recreate
