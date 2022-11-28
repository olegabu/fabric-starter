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

So after start the new organization will  become a member of the existing Network. 
See [Start an organization node](network-node-start.md) for detailed environment
description.

#### Add new organization to consortium

Members of the Network communicate with each other inside channels. The owner of the channel first creates a channel and
then adds member organizations to it. To create a channel the owner organization must be a part of the consortium. 
Only the network member with corresponding permissions can add organization to a consortium. In the network deployed by 
Fabric Starter it is only the administrator of the first organization node. 

To add a new organization to the consortium the administrator provides the IP address of the organization node and 
the organization name in the administration dashboard.

