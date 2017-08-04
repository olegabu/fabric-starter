# REST calls



## Configuration

### Network configuration

```
curl -i http://localhost:8081/config

```

### Genesis block 

(incomplete)

```
curl -i http://localhost:8081/genesis

```




## Channel

### Channels list

Query to fetch channels list

```
curl -i http://localhost:8081/channels

```


### Create channel

_Will be filled later_

```
curl -iXPOST http://localhost:8081/channels -d '{...}'

```


### Join channel

_Will be filled later_

```
curl -iXPOST http://localhost:8081/channels/:channelName/peers -d '{...}'

```


### Channel info

Query for Channel Information

```
curl -i http://localhost:8081/channels/<channelName>

```

### Channel binary config
(incomplete)

```
curl -i http://localhost:8081/channels/<channelName>/config

```