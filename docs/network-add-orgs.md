# Add organizations to Network

#### Adding an organization

After the first organization node has been deployed other organization nodes can be created and connected to the Network.
Deployment for the new organization is the same as described in (see [Start an organization node](network-node-start.md))
Though the IP of the first organization node should be provided in the `org_env` file 
along with the other environment variables:

```bash
...
export BOOTSTRAP_IP='External IP of the first organization orderer node'
...
```    

See [Start an organization node](network-node-start.md) for detailed environment
description.

After the node starts, the new organization becomes a member of the existing Network, that is, 
it participates in the `common` channel and the service chaincode along with the established connectivity. 
Owners of other channels (i.e. those who created them) can add organization to their channels. 

#### Add new organization to consortium

To allow organization to create a channel or install the chaincodes the organization has to be added 
to the consortium. Currently, only the administrator of the first organization node can manage a consortium. 

To add a new organization to the consortium the administrator provides the IP address of the organization node and 
the organization name in the administration dashboard.

