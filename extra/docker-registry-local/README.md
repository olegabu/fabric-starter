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

## Apply locally built images 

If you build images on local machine for debug or test purposes and are not going to push them to docker's repository 
you can them by pushing to the local registry:

```bash
    docker build -t new/image ...
    docker tag new/image localhost:5000/new/image
    docker push localhost:5000/new/image
```  

`Do not re-execute` the _start-docker-registry-local.sh_ to prevent pulling and overriding the new image
by old image from the remote repository.   