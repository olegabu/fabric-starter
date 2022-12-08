# Add organization to network

#### Adding an organization to a network

Starting new organization node is performed the same way as described in [Start an organization node](network-node-start.md).
 
To have an organization participate in an existing network some connectivity parameters should be specified:

- IP address of the bootstrap node: 
```bash
export BOOTSTRAP_IP='IP address of the bootstrap node'
```

- if custom orderer domain is used on the network's bootstrap node specify it:  
```bash
export ORDERER_DOMAIN=osn-example.com 
```

When started, the new node establishes connection with the bootstrap node, joins to the `common` channel 
and exchanges connectivity information with other network nodes.

New organizations can then be invited to other channels created by other organizations. 

#### Add organization to consortium

To get permissions to create own channels the organization has to be added to the consortium. 
This can be done in the Administration dashboard by the administrator of the bootstrap organization.  
