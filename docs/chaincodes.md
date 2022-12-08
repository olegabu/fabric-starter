# Install chaincodes


User can create custom chaincodes, install them and instantiate in channels. The chaincode should be 
packaged before installation according to Fabric specification.

- For Fabric 1.x archive the chaincode directory:

  ```zip -r ${zipArchiveName} ./${chaincodeFolder}/*```

- For Fabric 2.x the chaincode should be packaged for example by the Fabric CLI:


  ```bash
  peer lifecycle chaincode package ${chaincodeName}.tar.gz \
  --path ${chaincodeFolder} --lang node --label ${chaincodeName}_1.0
  ```


The `cli.peer` container can be used to package the chaincode:
 
- copy source code  folder to `./chaincode` folder (as it's shared with the `cli` container)
- prepare package:


  ```bash
  docker exec -t cli.peer0.${ORG}.${DOMAIN} peer lifecycle chaincode \
  package /opt/chaincode/${chaincodeName}.tar.gz --path /opt/chaincode/${chaincodeFolder} \
  --lang node --label ${chaincodeName}_1.0
  ```

Install the prepared package and instantiate the chaincode in the channel using Admin dashboard or REST API.
