# Local Docker Registry for Multihost deployments 
## Docker-Machine & Virtualbox    

To use local docker registry with virtualbox multihost network and avoid remote downloading 
Fabric's docker images for each virtual machine start local docker registry:

```bash
extra/docker-registry-local/start-docker-registry-local.sh 
``` 

New network can be created then as described in [Multi host deployment](docs/multihost.md)  

- Virtualbox's virtual machines will see the docker registry on `192.168.99.1:5000` 
(or _vmboxnet_ adapter server address). If this address is determined incorrectly it may 
be set explicitly:

```bash
export DOCKER_REGISTRY=192.168.56.1:5000
```     
Then create the network.  
  
- On the local host the local registry is started at _localhost:5000_ by default. 
If you like to use another address\port set this before starting:

```bash
export DOCKER_REGISTRY_LOCAL=localhost:5000
extra/docker-registry-local/start-docker-registry-local.sh 
```

- Re-execute the `start-docker-registry-local.sh ` script if images were changed at Docker hub to renew them.