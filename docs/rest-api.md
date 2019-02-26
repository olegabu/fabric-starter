# Use REST API to query and invoke chaincodes

Login into *org1* as *user1* and save returned token into env variable `JWT` which we'll use to identify our user 
in subsequent requests:
```bash
JWT=`(curl -d '{"username":"user1","password":"pass"}' --header "Content-Type: application/json" http://localhost:4000/users | tr -d '"')`
```

Query channels *org1* has joined
```bash
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels
```
returns
```json
[{"channel_id":"common"},{"channel_id":"org1-org2"}]
``` 

Query status, orgs, instantiated chaincodes and block 2 of channel *common*:
```bash
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels/common
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels/common/chaincodes
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels/common/orgs
curl -H "Authorization: Bearer $JWT" http://localhost:4000/channels/common/blocks/2
```

Invoke function `put` of chaincode *reference* on channel *common* to save entity of type `account` and id `1`:

With `["targets"]`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
http://localhost:4000/channels/common/chaincodes/reference -d '{"fcn":"put","args":["account","1","{name:\"one\"}"],"targets":["peer0.org1.example.com","peer1.org1.example.com:7051"]}'
```
Without `["targets"]`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
http://localhost:4000/channels/common/chaincodes/reference -d '{"fcn":"put","args":["account","1","{name:\"one\"}"]}'
```


Query function `list` of chaincode *reference* on channel *common* with args `["account"]`:

With `["targets"]`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
'http://localhost:4000/channels/common/chaincodes/reference?channelId=common&chaincodeId=reference&fcn=list&args=%5B%22account%22%5D&targets=%5B%22peer0.org1.example.com%22%2C%22peer1.org1.example.com%3A7051%22%5D'
```

Without `["targets"]`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
'http://localhost:4000/channels/common/chaincodes/reference?channelId=common&chaincodeId=reference&fcn=list&args=%5B%22account%22%5D'
```
