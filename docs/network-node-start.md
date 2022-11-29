# Start an organization node 

#### Environment variables

Configuration of an organization is set by variables defined in the environment or in the org_env file.

Possible environment variables are listed in the`org_env_sample` file. 

Minimum set of vars is:

- Organization properties:

```bash
export ORG='Name of your organization'
export DOMAIN='Domain of your organization'
export MY_IP='External IP of the organization node server'
```    

- Orderer properties:
```bash
export ORDERER_TYPE= {SOLO, RAFT1, RAFT3} 
```


#### Start organization
To start the organization Network run `./deploy-2x.sh`

One node is already a Network. The network can be extended by joining other orgs, 
see [Add organizations to Network](network-add-orgs.md).

The `./clean.sh` script can be used to clean environment and organization artifacts. 
