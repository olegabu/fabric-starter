# Start Raft Ordering Service

## On different nodes


Configure environment. 
```bash
export DOMAIN=example.com

export DOCKER_COMPOSE_ORDERER_ARGS="-f docker-compose-orderer.yaml -f docker-compose-orderer-ports.yaml"

export RAFT0_PORT=7050 \
       RAFT1_PORT=7150 \
       RAFT2_PORT=7250
       
export ORG2_RAFT_NAME_1=raft3 \
       ORG2_RAFT_NAME_2=raft4 \
       ORG2_RAFT_NAME_3=raft5
```

* Org1 node: start `raft` orderers:  
```bash
raft/1_raft-start-3-nodes.sh 
```

* Org2 Node: prepare new ordrerer node config 
```bash
ORG=${org2} ORDERER_NAME=${ORG2_RAFT_NAME_1} raft/2_raft-prepare-new-consenter.sh
```

* Org1 node: add new orderer node config to system channel
```bash
ORG=${org1} RDERER_NAME=raft0 raft/3_raft-add-consenter.sh ${ORG2_RAFT_NAME_1} ${ORG2_DOMAIN:-${DOMAIN}} ${RAFT0_PORT}
```
* Wait for new config is replicated between nodes 

* Org2 node: Start orderer:
```bash
ORG=${org2} ORDERER_NAME=${ORG2_RAFT_NAME_1} raft/4_raft-start-consenter.sh www.${domain1}
```

