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

export WORK_DIR=./ # path to fabric-starter folder

export DOCKER_COMPOSE_ORDERER_ARGS="-f docker-compose-orderer.yaml -f docker-compose-orderer-multihost.yaml"

export RAFT0_PORT=7050 \
       RAFT1_PORT=7150 \
       RAFT2_PORT=7250
       
export ORG2_RAFT_NAME_1=raft3 \
       ORG2_RAFT_NAME_2=raft4 \
       ORG2_RAFT_NAME_3=raft5
```

Manually prepare `hosts` file which will be mapped to containers' `/etc/hosts` so containers could find each other:  
* **Org1**:
```bash
mkdir crypto-config
# Write dns-record into the file `hosts_orderer`:
echo "$ORG2_IP www.${ORDERER_DOMAIN2} orderer.${ORDERER_DOMAIN2} raft4.${ORDERER_DOMAIN2} raft5.${ORDERER_DOMAIN2} peer0.org2.${DOMAIN}" > crypto-config/hosts_orderer
```


* **Org2** 
```bash
mkdir crypto-config
# Write dns-record into the file `hosts_orderer`:
echo "$ORG1_IP www.${ORDERER_DOMAIN1} orderer.${ORDERER_DOMAIN1} raft1.${ORDERER_DOMAIN1} raft2.${ORDERER_DOMAIN1} peer0.org1.${DOMAIN}" > crypto-config/hosts_orderer
```



### Start the ordering service

* **Org1** node: start 3 instances of`raft` orderers:  
```bash
DOMAIN=$ORDERER_DOMAIN1 raft/1_raft-start-3-nodes.sh 
```

### Add new raft-node to the consensus

* **Org2** Node: prepare new `raft` ordrerer node config 
```bash
DOMAIN=$ORDERER_DOMAIN2 raft/2_raft-prepare-new-consenter.sh
```

* **Org1** node: add new orderer node config to system channel
```bash
DOMAIN=$ORDERER_DOMAIN1 raft/3_2_raft-add-consenter.sh ${ORG2_RAFT_NAME_1} ${ORDERER_DOMAIN2:-${DOMAIN}} ${RAFT0_PORT}
```
* Wait for new config is replicated between nodes 

* **Org2** node: Start orderer:
```bash
DOMAIN=$ORDERER_DOMAIN2 raft/4_raft-start-consenter.sh www.${ORDERER_DOMAIN1}
```

This way any number of raft-ordering nodes can be added to the consensus. 