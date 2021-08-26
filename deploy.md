#### Org1
Adjust environment in file `org_env`,

    ORG - org name
    DOMAIN - domain
    MY_IP - external Ip

Start org1:
```bash
FABRIC_VERSION=2.3 FABRIC_STARTER_VERSION=2x ./deploy-2x.sh 
```


#### OrgN
Adjust environment in file `org_env`,

    ORG - org name
    DOMAIN - domain
    MY_IP - external Ip
    BOOTSTRAP_IP - external Ip of the org1
       
Start orgN:
```bash
FABRIC_VERSION=2.3 FABRIC_STARTER_VERSION=2x ./deploy-2x.sh 
```


### Chaincode
Assuming environment in file `org_env` is configured for curretn org. 


#### Install from source code:
- copy source code  folder to `./chaincode` folder (as it's shared with the `cli` container)
- install chaincode:
    ```bash
    ./chaincode-install ${chaincodeName} ${chaincodeVersion} /opt/chaincode/${ccfolder}
    ```
 

#### Install from package (Fabric 2x)
- prepare package by yourself according to 2x lifecycle process:
    ```bash
        CC_LABEL=${chaincodeName}_${chaincodeVersion} # required (!)
        peer lifecycle chaincode package ${chaincodeName}.tar.gz --label $CC_LABEL --path $chaincodePath --lang $lang 
    ```
  Example
    ```bash
        peer lifecycle chaincode package account.tar.gz --label account_1.0 --path /opt/chaincode/account --lang golang
    ```
- install the package:
    ```bash
    ./chaincode-install-package.sh ${chaincodeName}.tar.gz
    ```

#### Instantiate (commit) chaincode
- copy private collection definition file to `./chaincode` folder if any
- instantiate previously installed chaincode
    ```bash
    ./chaincode-instantiate.sh ${channel} ${chaincodeName} ${initRequired} ${chaincodeVersion} ${privateCollectionPath} ${endorsementPolicy}
    ```
Example:
```bash
    ./chaincode-instantiate.sh common account '' 1.0 
```

