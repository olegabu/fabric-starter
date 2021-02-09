# Use REST API to query and invoke chaincodes

**Note:** Here you can find some examples of using rest API. 
Full list of provided functions can be found at a running node on the Swagger generated page `http://<node IP>:4000/api-docs` 

Login into *org1* as *user1* and save returned token into env variable `JWT` which we'll use to identify our user 
in subsequent requests:
```bash
JWT=`(curl -d '{"username":"user1","password":"pass"}' -H "Content-Type: application/json" http://localhost:4000/users | tr -d '"')`
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

Invoke function `put` of chaincode *reference* on channel *common* to save entity of type `account` and id `1`.

With `["targets"]`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
http://localhost:4000/channels/common/chaincodes/reference -d '{"fcn":"put","args":["account","1","{name:\"one\"}"],"targets":["peer0.org1.example.com","peer0.org2.example.com"]}'
```
Without `["targets"]` submits for endorsement to all orgs required by the endorsement policy:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
http://localhost:4000/channels/common/chaincodes/reference -d '{"fcn":"put","args":["account","1","{name:\"one\"}"]}'
```
To wait for transaction to commit add `waitForTransactionEvent`:
```bash
curl -H "Authorization: Bearer $JWT" -H "Content-Type: application/json" \
http://localhost:4000/channels/common/chaincodes/reference -d '{"fcn":"put","args":["account","1","{name:\"one\"}"],"waitForTransactionEvent":true}'
```

Query function `list` of chaincode *reference* on channel *common* with args `["account"]`.

With `["targets"]`:
```bash
curl -H "Authorization: Bearer $JWT" \
'http://localhost:4000/channels/common/chaincodes/reference?fcn=list&args=%5B%22account%22%5D&targets=%5B%22peer0.org1.example.com%22%5D'
```
Without `["targets"]` returns query results from all orgs of the channel:
```bash
curl -H "Authorization: Bearer $JWT" \
'http://localhost:4000/channels/common/chaincodes/reference?fcn=list&args=%5B%22account%22%5D'
```
Get an array of json objects not strings by adding `unescape` parameter:
```bash
curl -H "Authorization: Bearer $JWT" \
'http://localhost:4000/channels/common/chaincodes/reference?fcn=list&args=%5B%22account%22%5D&unescape=true'
```

Get one record with function `get` of chaincode *reference* on channel *common* with args `["account","1"]`.

```bash
curl -H "Authorization: Bearer $JWT" 'http://localhost:4000/channels/common/chaincodes/reference?fcn=get&args=%5B%22account%22%2C%221%22%5D'
```
