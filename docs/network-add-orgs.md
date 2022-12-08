# Add organizations to the network

#### Adding an organization to the network

To add another organization to the network deploy it according to the
[Start an organization node](network-node-start.md) chapter providing some additional
configuration parameters.

Obtain the IP address of the bootstrap node (usually it is the first node in the network). 
Provide the adrress in the BOOTSTRAP_IP variable: 


```bash
export BOOTSTRAP_IP='External IP of the first organization orderer node'
```

When using the Raft consensus (see [Start Raft Ordering Service](docs/raft.md)) also obtain and provide 
the value for the ORDERER_DOMAIN:

```bash
export ORDERER_DOMAIN=osn-${ORG}.${DOMAIN} 
```

When started, the new node is added to the `common` channel and establishes connection with 
other network nodes using information from the service chaincode in the `common` channel.  

New organizations then can be invited to other channels used by applications or organization groups. 

#### Add organization to consortium

To allow organization to create own channels the organization has to be added 
to the consortium. This can be done in the Administration dashboard. Currently, 
only the administrator of the first organization can manage a consortium.  
