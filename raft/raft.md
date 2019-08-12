# Start Raft Ordering Service

## Configure environment on different nodes

```bash
export DOMAIN=<>

export WORK_DIR=$PWD/fabric-starter # path to fabric-starter folder

export DOCKER_COMPOSE_ORDERER_ARGS="-f docker-compose-orderer.yaml -f docker-compose-orderer-multihost.yaml"

export RAFT0_PORT=7050 \
       RAFT1_PORT=7150 \
       RAFT2_PORT=7250
       
export ORG2_RAFT_NAME_1=raft3 \
       ORG2_RAFT_NAME_2=raft4 \
       ORG2_RAFT_NAME_3=raft5
```

Manually prepare `hosts` file which will be mapped to containers' `/etc/hosts` so containers could find each other:  
* Org1:
```bash
mkdir crypto-config
# Write dns-record into the file `hosts_orderer`:
echo "<org2-IP> raft3.${DOMAIN} raft4.${DOMAIN} raft5.${DOMAIN}" > crypto-config/hosts_orderer
```


* Org2 
```bash
mkdir crypto-config
# Write dns-record into the file `hosts_orderer`:
echo "<org1-IP> www.raft0.${DOMAIN} raft0.${DOMAIN} raft1.${DOMAIN} raft2.${DOMAIN}" > crypto-config/hosts_orderer
```



## Start the ordering service

* Org1 node: start `raft` orderers:  
```bash
raft/1_raft-start-3-nodes.sh 
```

* Org2 Node: prepare new ordrerer node config 
```bash
ORDERER_NAME=${ORG2_RAFT_NAME_1} raft/2_raft-prepare-new-consenter.sh
```

* Org1 node: add new orderer node config to system channel
```bash
ORDERER_NAME=raft0 raft/3_2_raft-add-consenter.sh ${ORG2_RAFT_NAME_1} ${ORG2_DOMAIN:-${DOMAIN}} ${RAFT0_PORT}
```
* Wait for new config is replicated between nodes 

* Org2 node: Start orderer:
```bash
ORDERER_NAME=${ORG2_RAFT_NAME_1} raft/4_raft-start-consenter.sh www.${domain1}
```

