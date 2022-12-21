# Start an organization node 

To start a bootstrap node of the new Blockchain network or as a part of  existing network 
configure node settings and run the deployment script.

Settings are configured by  variables specified in shell environment or in the `org_env` file.

Define organization name and domain, consensus type, and the external IP address of the node.

#### Environment variables
Possible environment variables are listed in the`org_env_sample` file.

Copy `org_env_sample` to the `org_env` file and adjust values for the organization configuration or 
export the variables to the shell environment. 

The `org_env_sample` file contains variables of the following types: 

- Organization properties:

```bash
export ORG='org1'
export DOMAIN='example.com'
export MY_IP='External IP of the organization node'
export ENROLL_SECRET=adminpw
```    

- Orderer properties:
```bash
export ORDERER_TYPE=SOLO
#export ORDERER_TYPE=RAFT 
```
- Ports:
```bash
export API_PORT=4000
...
```

#### Start organization node
After settings are configured run `./deploy-2x.sh`

One node can be seen as a Blockchain network. The network can be extended by joining other orgs, 
see [Add organizations to Network](network-add-orgs.md).

#### Clean organization artifacts
The `./clean.sh` script can be used to clean workspace - remove organization artifacts, 
docker containers, the ledger.

To avoid removing organization's crypto-material and certificates use 
```bash
./clean.sh data
``` 
