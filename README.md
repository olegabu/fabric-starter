## API server for Hyperledger Fabric 1.0

A Node.js app that uses **__fabric-client__** & **__fabric-ca-client__** 
[Node.js SDK](https://github.com/hyperledger/fabric-sdk-node) APIs to interface with peers of 
[Hyperledger Fabric](https://github.com/hyperledger/fabric) network. Based on the sample app 
[balance transfer](https://github.com/hyperledger/fabric-samples/tree/release/balance-transfer).

A REST API endpoint is open for web applications or other systems to transact on the fabric blockchain network. 
A test web application is served from an http endpoint to invoke chaincodes and display transaction and blockchain info. 

The API server is meant to be run by each member organization; it connects to the organization's CA to get certs for end 
users and passes these certs to authenticate to blockchain peers as belonging to the organization. 

The test web application allows the end user to enroll with the CA to transact as a member of the organization running 
the API server. Please note that connection to the API server and the test web app is not password protected. 
 
A sample network of two organizations and a solo orderer can be started by a 
[docker-compose script](ledger/docker-compose-template.yaml) that you can customize with your own domain and 
organization names in [network.sh](network.sh) setup script.

### Prerequisites:

* [Docker](https://www.docker.com/products/overview) - v1.12 or higher
* [Docker Compose](https://docs.docker.com/compose/overview/) - v1.8 or higher
* [Git client](https://git-scm.com/downloads) - needed for clone commands
* **Node.js** v6.9.0 - 6.10.0 ( __Node v7+ is not supported__ )

*Optional*: if you'd like to deploy java chaincode you'll need a build of Fabric 1.0 with java enabled. 
Download and install these docker images instead of the ones available in the release:

```
curl -O https://s3.amazonaws.com/synswap/install/fabric-images.tgz
docker load -i fabric-images.tgz
```

### Setup

[network.sh](network.sh) script will create docker-compose.yaml, configtx.yaml and cryptogen.yaml files with your custom
  org names; will run cryptogen to generate crypto material and configtxgen for the orderer genesis block and config
  transactions.
  
  The network can be started from the generated docker-compose.yaml; it is run by these docker instances:
  * 2 CAs
  * A SOLO orderer
  * 4 peers (2 peers per Org)
  
  Once the network is running you can start the API and web app servers. 

```
 # generate customized yaml files and generate crypto and channel artifacts (don't run it twice)
 sudo ./network.sh
 
 # start the network
 cd ledger
 docker-compose up
```

Open [http://localhost:4001/ui](http://localhost:4001/ui) for org1 and 
[http://localhost:4002/ui](http://localhost:4002/ui) for org2.
 
 You can also interact with the API server directly with an http client of your choice and test with these 
 [sample requests](https://github.com/hyperledger/fabric-samples/tree/release/balance-transfer#sample-rest-apis-requests).

### Run Api in dev mode

Dev mode supports editing the files without rebuilding container (for the most of the files, but not for all of them!). 
For more details see `ledger/docker-compose-server-dev.yaml` file.

```
 docker-compose -f ledger/docker-compose-server-dev.yaml up
```

### Network configuration considerations

You have the ability to change configuration parameters by editing [network-config.json](server/network-config.json).

#### IP Address and PORT information

If you choose to customize your docker-compose yaml file by hardcoding IP Addresses and PORT information for your peers 
and orderer, then you MUST also add the identical values into the network-config.json file. 
The paths shown below will need to be adjusted to match your docker-compose yaml file.

```
		"orderer": {
			"url": "grpcs://x.x.x.x:7050",
			"server-hostname": "orderer0",
			"tls_cacerts": "../artifacts/tls/orderer/ca-cert.pem"
		},
		"org1": {
			"ca": "http://x.x.x.x:7054",
			"peer1": {
				"requests": "grpcs://x.x.x.x:7051",
				"events": "grpcs://x.x.x.x:7053",
				...
			},
			"peer2": {
				"requests": "grpcs://x.x.x.x:7056",
				"events": "grpcs://x.x.x.x:7058",
				...
			}
		},
		"org2": {
			"ca": "http://x.x.x.x:8054",
			"peer1": {
				"requests": "grpcs://x.x.x.x:8051",
				"events": "grpcs://x.x.x.x:8053",
				...			},
			"peer2": {
				"requests": "grpcs://x.x.x.x:8056",
				"events": "grpcs://x.x.x.x:8058",
				...
			}
		}

```

#### Discover IP Address

To retrieve the IP Address for one of your network entities, issue the following command:

```
# this will return the IP Address for peer0
docker inspect peer0 | grep IPAddress
