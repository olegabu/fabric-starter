# Start an organization node 

#### Environment vraiables

At first adjust the environment in the `org_env` file. Most of the environment variables are listed in the
`org_env_sample` file. To deploy the one organization network provide the following vars:

```bash
export ORG='Name of your organization'
export DOMAIN='Domain of your organization'
export MY_IP='External IP of the organization node server'
```    
Some other variables:
ORDERER_TYPE -- sets the consensus algorithm: `SOLO`, `RAFT1`, `RAFT3`

Once it is required to separate peer0 name and org parts of the peer container name with some other symbol than dot,
set all of these variables to `peer0{separationSymbol}` (e.g. 'peer0-')

```bash
export PEER_ADDRESS_PREFIX_TEMPLATE=peer0-
export PEER_ADDRESS_PREFIX=peer0-
export BOOTSTRAP_PEER_PREFIX=peer0-
```

Also see [Use LDAP](docs/ldap.md) for LDAP-specific environment variables.


#### Organization start script
To start the organization Network run

```bash
./deploy-2x.sh 
```

One organization node is the smallest network itself that could be used for development purposes. 
To add another organization nodes see [Add organizations to Network](docs/network-add-orgs.md).

To delete the organization run

```bash
./clean.sh 
```

This will stop and delete all the organization Network docker containers and volumes, as well as certificates,
keys, applications etc. To clean up certificates and keys or data and applications only 
run `./clean.sh` script with 'certs' or 'data' options respectively.
