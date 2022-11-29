# Add organizations to Network

#### Adding an organization to Network

To add a new organization to the Network provide the following environment variables along with the minimum ones:

```bash
...
export BOOTSTRAP_IP='External IP of the first organization orderer node'
export ORDERER_DOMAIN=osn-${ORG}.${DOMAIN} #For Raft consensus

```    

Then node start the node as the first one (See [Start an organization node](network-node-start.md)). 
The node establishes connection with the Network and is added to the `common` service channel, 
the service chaincode is instantiated.

Owners of other channels (creators) can add organization to their channels. 

#### Add organization to Consortium

To allow organization to create channels the organization has to be added 
to the consortium. Currently, only the administrator of the first organization can manage a consortium. 

To add a new organization to the consortium the administrator uses the administration dashboard providing 
the name and the IP address of the new organization.

