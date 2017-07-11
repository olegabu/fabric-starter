#!/usr/bin/env bash

curl -XPOST -d @deployRemote.json http://vp1:7050/chaincode


curl -XPOST -d  '{"jsonrpc": "2.0", "method": "deploy",  "params": {"type": 1,"chaincodeID": {"path": "github.com/olegabu/catbond/chaincode","language": "GOLANG"}, "ctorMsg": { "args": ["aW5pdA=="] },"secureContext": "issuer0", "attributes": ["role"]},"id": 0}' http://vp1:7050/chaincode