# Token transfer example

There are two different ways of running the Token transfer example:

- [Deployment through the Admin panel](#deployment1)
- [Deployment with the `./network-local-create.sh`](#deployment2)
 

<a name="deployment1"></a>
## Deployment through the Admin panel

Run `./generate-zip-files.sh`, it will produce two zip packages for the webapp and the chaincode in **build** folder. 
Then, upload `token-transfer-chaincode.zip` to the admin panel in **Install chaincode** section, and then instantiate the token-transfer-chaincode, 
which appears in the `Installed chaincodes` list. 

To run webapp, upload `token-transfer.zip` to the admin panel in **Install Web App** section.

<a name="deployment2"></a>
## Deployment with the `./network-local-create.sh`

To deploy chaincode and webapp with the deployment script:

Run the following command:
```
CHAINCODE_INSTALL_ARGS="token-transfer-chaincode 1.0 /opt/chaincode/java/token-transfer-chaincode java" \
CHAINCODE_INSTANTIATE_ARGS="common token-transfer-chaincode" \
CHAINCODE_HOME=./examples/fabric-token-transfer/chaincode \
WEBAPP_HOME=./examples/fabric-token-transfer/token-transfer-webapp \
./network-create-local.sh
```



