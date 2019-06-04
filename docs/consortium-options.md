<a name="consortiumtypes"></a>
## Open consortium.

Type of network with open consortium can be governed by itself (or to say it right by the network's members). 
The first type of network-governance is `Open Network` or `Open Consortium network`.
With this type of deployment any organization (not only a system "administrative" organization) - 
member of the blockchain network - can add itself to the consortium.

### Quick deploy such  



To deploy organizations for such type of network ony by one we use the `CONSORTIUM_CONFIG` variable when start orderer:
```bash
#export WWW_PORT=81 # needed if the orderer and a first org are started on the same host   
CONSORTIUM_CONFIG=InviteConsortiumPolicy docker-compose -f docker-compose-orderer.yaml -f docker-compose-open-net.yaml -f orderer-multihost.yaml up -d
```

Then start an organization you can use scrpt:
./node-create <org-name> <BOOTSTRAP(orderer) IP> <ORG IP>

```bash
./node-create org1 192.168.99.100 192.168.99.101
```

Node can also be started manually using `docker-compose`:

```bash
#export DOCKER_REGISTRY=192.168.99.1:5000 # needed if custom docker registry is used
ORG=org1 MY_IP=192.168.99.yy BOOTSTRAP_IP=192.168.99.xx MULTIHOST=true docker-compose -f docker-compose.yaml -f docker-compose-open-net.yaml -f multihost.yaml up -d 
```

To start other organizations you can provision a host manually or with `docker-machine`: 

```bash
    ./host-create.sh org2
``` 

and start the new organization's node with same command as above: 
```bash
./node-create org2 192.168.99.100 192.168.99.102
```

or by using `docker-compose`

```bash
#export DOCKER_REGISTRY=192.168.99.1:5000 # needed if custom docker registry is used
ORG=org2 MY_IP=192.168.99.zz BOOTSTRAP_IP=192.168.99.xx MULTIHOST=true docker-compose -f docker-compose.yaml -f docker-compose-open-net.yaml -f multihost.yaml up -d 
```




##### `Invite` and `Majority` types of consortium governance are coming.       

