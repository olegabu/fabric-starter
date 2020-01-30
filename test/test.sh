#!/bin/bash


if [ "${MULTIHOST}" = true ]; then
    LOCAL_PEER_PORT=7051
    eval $(docker-machine env org2.example.com)
else 
    LOCAL_PEER_PORT=8051
fi

echo $LOCAL_PEER_PORT