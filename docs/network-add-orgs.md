# Add organizations to Network

#### Create a new organization

For the new organization specify the environment in the org_env file: 
```bash
export ORG='Name the new organization'
export DOMAIN='Domain of the new organization'
export MY_IP='External IP of the new organization node'
export BOOTSTRAP_IP='External IP of the first organization orderer node'
```    

Run the `./deploy-2x.sh` command to deploy and start the new organization. To become a member of the existing Network 
provide the BOOTSRAP_IP -- currently it's the IP address of the Network  _orderer_ node.

See  [Start an organization node](network-node-start.md) for detailed environment
description.

#### Join the Network

The new organization can be added to the consortium by a member of this network.
Then the new organization passes the ip address of the newly deployed node to the network's member 
and this member adds the organization to Consortium by it's administration dashboard.
After that the new organization can create own channels, add other organizations to the own channels and 
even invite more organizations to the network itself.     

