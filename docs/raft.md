# Start Raft Ordering Service

RAFT consensus type requires at least 3 separate nodes to function. To workaround this requirement for dev and test purposes
we start three raft-nodes on the first orderer node. This allows us to have functioning RAFT-service. 
Then we are able to join any quantity of raft-nodes one by one to the functioning service. 
  

## Start raft in local mode
You can start RAFT ordering service locally for dev or test purposes.
Run script [raft-start-local.sh](../raft-start-local.sh).
```bash
./raft-start-local.sh
```


## Start RAFT-service on separate servers (example for two Orgs)
### Configure environment on different organization nodes

We assume we are starting three RAFT nodes on the first server; 
thus we define names and ports for the raft-orderers.
Execute this on both organization nodes:

```bash
export DOMAIN=example.com
export ORDERER_DOMAIN1=osn-org1.$DOMAIN
export ORDERER_DOMAIN2=osn-org2.$DOMAIN
export ORG1_IP=<IP1>
export ORG2_IP=<IP2>

#export FABRIC_STARTER_HOME=/home/docker # for docker-machine deployment

export RAFT0_CONSENTER_PORT=7050 \
       RAFT1_CONSENTER_PORT=7150 \
       RAFT2_CONSENTER_PORT=7250
```

### Start the ordering service

* **Org1** node: start 3 instances of`raft` orderers:  
```bash
./clean.sh
DOMAIN=$ORDERER_DOMAIN1 raft/1_raft-start-3-nodes.sh
# see note below to start any number of raft instances on one server
```

### Add new raft-node to a running raft ordering service

* **Org2** Node: prepare new `raft` orderer config 
```bash
./clean.sh
DOMAIN=$ORDERER_DOMAIN2 raft/2_raft-prepare-new-consenter.sh
```

* **Org1** node: add new orderer node config to system channel
```bash
DOMAIN=$ORDERER_DOMAIN1 raft/3_2_raft-add-consenter.sh orderer ${ORDERER_DOMAIN2:-${DOMAIN}} ${ORG2_IP} ${RAFT0_CONSENTER_PORT} 79 
```
* Wait for new config is replicated between nodes 

* **Org2** node: Start orderer:
```bash
DOMAIN=$ORDERER_DOMAIN2 raft/4_raft-start-consenter.sh ${ORDERER_DOMAIN1} www.${ORDERER_DOMAIN1}:79 ${ORG1_IP}
```

* **Org2** node: Add other Raft instances DNS information (if any)
* Repeat on other org's hosts either 
```bash
raft/update-dns.sh osn-org3.example.com:192.168.99.103 osn-org5.example.com:192.168.99.103
``` 

This way any number of raft-ordering nodes can be added to an ordering service. 


#### Starting arbitrary number of raft instances  manually (for the first node there should be at least 3 raft instances):

```bash

  export ORDERER_PROFILE=Raft ORDERER_NAMES='orderer:7050,raft1:7150,raft2:7250' ORDERER_DOMAIN=$ORDERER_DOMAIN1
  # Start the first instance (with generating crypto-material for all ORDERER_NAMES)
  ORDERER_NAME=orderer docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml up -d  
  # start rest instances
  COMPOSE_PROJECT_NAME=raft1 ORDERER_NAME=raft1 ORDERER_GENERAL_LISTENPORT=7150 \
     docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml up -d --no-deps orderer
  COMPOSE_PROJECT_NAME=raft2 ORDERER_NAME=raft2 ORDERER_GENERAL_LISTENPORT=7250 \
     docker-compose -f docker-compose-orderer.yaml -f docker-compose-orderer-domain.yaml -f docker-compose-orderer-ports.yaml up -d --no-deps orderer

```