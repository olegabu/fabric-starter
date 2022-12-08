# Start an organization node 
<!-- to start need to set config and run script
new network or add to network
choose consensus
domain for orgs
org name
ip
-->
To start an organization node as a part of the new Blockchain network or to add it 
to the existing network provide the configuration settings and run the deployment script.


Before deploying the organization node choose the consensus type, domain and organization names, and 
get the external IP address of the server.

#### Environment variables
Organization is configured by variables defined in the environment or in the `org_env` file. 
Possible environment variables are listed in the`org_env_sample` file.

Copy `org_env_sample` to the `org_env` file and adjust values for the organization configuration or 
export the variables to the environment. 

The `org_env_sample` file contains variables of the following types: 

- Organization properties:

```bash
export ORG='Name of your organization'
export DOMAIN='Domain of your organization'
export MY_IP='External IP of the organization node server'
export ENROLL_SECRET='administrator password'
```    

- Orderer properties:
```bash
export ORDERER_TYPE={SOLO, RAFT1, RAFT3} 
```
- Ports:
```bash
export API_PORT=4000
...
```

#### Start organization node
To start the Hyperledger Fabric node run `./deploy-2x.sh`

One node is already a Blockchain Network. The network can be extended by joining other orgs, 
see [Add organizations to Network](network-add-orgs.md).

#### Clean organization artifacts
The `./clean.sh` script can be used to clean environment and organization artifacts and stop and remove
organization components containers.

To clean data but keep certs (or vice versa) for development purposes run
`./clean.sh data` or `./clean.sh certs`  