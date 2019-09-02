#!/usr/bin/env bash
pusdh ../../
    DOMAIN=${RAFT_DOMAIN1} ORDERER_NAME=raft0 ORDERER_DOMAIN=${RAFT_DOMAIN1} RAFT_NODES_COUNT=3 ../raft/1_raft-start-3-nodes.sh

popd
