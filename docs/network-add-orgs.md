# Add organizations to Network

#### Adding an organization

After the first organization node has been deployed (see [Start an organization node](network-node-start.md))
other organization nodes can be created and connected to the Network.

For the new organization specify the environment in the org_env file: 
```bash
export ORG='Name the new organization'
export DOMAIN='Domain of the new organization'
export MY_IP='External IP of the new organization node'
export BOOTSTRAP_IP='External IP of the first organization orderer node'
```    

Run the `./deploy-2x.sh` command to deploy and start the new organization. To become a member of the existing Network 
provide the BOOTSRAP_IP -- currently it's the IP address of the Network  _orderer_ node.

See [Start an organization node](network-node-start.md) for detailed environment
description.

#### Add new organization to consortium

Consortium defines a set of organizations in the Network that can make transactions with each other. The main communication 
mechanism in consortium is a channel. The new organization can be added to the consortium by the administrator 
of existing organization in the administration dashboard providing the name of the new organization, and it's 
node IP address. After that the new organization admin can create own channels, add other organizations to them and  
even invite other organizations to the Network itself.
