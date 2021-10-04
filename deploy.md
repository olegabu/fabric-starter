#### Org1
Adjust environment in file `org_env`,

    ORG - org name
    DOMAIN - domain
    MY_IP - external Ip

Start org1:
```bash
./deploy-2x.sh 
```


#### OrgN
Adjust environment in file `org_env`,

    ORG - org name
    DOMAIN - domain
    MY_IP - external Ip
    BOOTSTRAP_IP - external Ip of the org1
       
Start orgN:
```bash
./deploy-2x.sh 
```


### Chaincode
Assuming environment in file `org_env` is configured for curretn org. 


#### Install chaincode (from package (Fabric 2x))
- at first it's necessary to prepare install package in the `cli.peer` container:
    - copy source code  folder to `./chaincode` folder (as it's shared with the `cli` container)
    - prepare package:
        ```bash
      docker exec -t cli.peer0.${ORG}.${DOMAIN} peer lifecycle chaincode \
        package /opt/chaincode/${chaincodeName}.tar.gz --path /opt/chaincode/${chaincodeFolder} \
        --lang node --label ${chaincodeName}_1.0
        ```

    - on UI install the package and instantiate chaincode 
