# Install chaincodes


User can create custom chaincodes, install them and instantiate in channels. The chaincode should be 
packaged before installation.

- For Fabric 1.x archive the chaincode directory:

  ```zip -r ${zipArchiveName} ./${chaincodeFolder}/*```

- For Fabric 2.x the chaincode should be packaged for example by the Fabic CLI:


  ```bash
  peer lifecycle chaincode package ${chaincodeName}.tar.gz \
  --path ${chaincodeFolder} --lang node --label ${chaincodeName}_1.0
  ```


It is possible to package the chaincode in `cli.peer` container:
 
- copy source code  folder to `./chaincode` folder (as it's shared with the `cli` container)
- prepare package:


  ```bash
  docker exec -t cli.peer0.${ORG}.${DOMAIN} peer lifecycle chaincode \
  package /opt/chaincode/${chaincodeName}.tar.gz --path /opt/chaincode/${chaincodeFolder} \
  --lang node --label ${chaincodeName}_1.0
  ```

In admin dashboard (or using REST API) install the prepared package and instantiate the chaincode in the channel.
