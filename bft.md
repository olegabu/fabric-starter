```bash


./build-fabric-tools-extended.sh 2.3 2.3 '' && ./clean.sh; FABRIC_VERSION=2.3 FABRIC_STARTER_VERSION=2.3 \
    ./raft/0_raft-start-1-node.sh \
    && docker logs pre-install.orderer.example.com

./build-fabric-tools-extended.sh 2.3 2.3 '' && ./clean.sh; FABRIC_VERSION=2.3 FABRIC_STARTER_VERSION=2.3 \
    ./raft/1_raft-start-3-nodes.sh \
    && docker logs pre-install.orderer.example.com

    
#CHANNEL_AUTO_JOIN= \ 
FABRIC_VERSION=2.3 FABRIC_STARTER_VERSION=baas-test docker-compose -f docker-compose.yaml -f docker-compose-dev.yaml up -d --force-recreate

```