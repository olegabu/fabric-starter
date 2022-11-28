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

#### Join the Network 

By now the deployed Network is governed by itself (or to say it right by the network's members).
This type of network-governance is called `Invite-based`. With this type of deployment
any organization (and not a central system administrator), which is the member of the blockchain network can add new
organizations to consortium. The new organization can be added to the consortium in the administration dashboard
by providing it's node IP address.


After that the new organization can create own channels, add other organizations to the own channels and even invite
more organizations to the network itself. 


The network governance policy is defined by the CONSORTIUM_CONFIG environment variable. For the invite-based networks
it should be set to `InviteConsortiumPolicy`:

```bash
export CONSORTIUM_CONFIG=InviteConsortiumPolicy
```

The `Majority` governance type is coming.

