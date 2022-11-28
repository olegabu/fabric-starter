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

Consortium defines a set of organizations in the Network that can make transactions with each other. The main communication 
mechanism in consortium is a channel. The new organization can be added to the consortium by the administrator 
of existing organization in the administration dashboard providing the name of the new organization, and it's 
node IP address. After that the new organization admin can create own channels, add other organizations to them and  
even invite other organizations to the Network itself.
