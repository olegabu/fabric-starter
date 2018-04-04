# Starter Application for Hyperledger Fabric 1.0

## Network with one main org allowing dynamically adding unlimited number of new orgs 

 
To start network:

### Configuration
1.1) On **each node** configure common parameter in file 'env-common': 

```
DOMAIN - default: example.com 
MAIN_ORG - default: a
IP1, IP2, IP3 - ip addresses of nodes
```
If you like to deploy only two ORGs specify IP3 the same as IP2 (temporal workaround)

1.2) Configure parameters specific for particular node:

   'env-org-main' - parameters for main org:
```
        export IP_ORDERER=        #should be empty as main org is deployed on the same node as orderer 
        THIS_ORG=a
```   
   'env-org-b' - parameters for org 'b':
```
        export IP_ORDERER=x.x.x.x # IP #address of main\orderer node
        THIS_ORG=b
```   
   'env-org-c' - parameters for org 'c':
```
        export IP_ORDERER=x.x.x.x # IP #address of  main\orderer node
        THIS_ORG=c
```   

### Deployment

2.1) On each org you plan to include to network run the command to set corresponding environment:  
    Org 'a':      
    `source ./env-org-main`  
    Org 'b':  
    `source ./env-org-b`  
    Org 'c':  
    `source ./env-org-c`  
Note 'env-common' is also called from the 'env-org-xxx' scripts

2.2) On each org you like to include into initial deployment (except main node'a') generate the crypto-material:

Org 'b':  
       `./org-generate-crypto.sh`  
Org 'c':  
       `./org-generate-crypto.sh`

2.3) On org 'a' run commands:  
```
 ./main-start-node.sh
 ./main-register-new-org.sh b $IP2
 ./main-register-new-org.sh c $IP3 b        #if you like to include org 'c'
```

This starts network on node a, creates channel 'common'; when register new orgs new bilateral channels ('a-b', 'a-c') 
are automatically created; then orgs 'b' and 'c' are registered in channels 'common', 'a-b', 'a-c'.
The third parameter 'b' is added at registering org 'c' in order to create the channel 'b-c' same time as organization 'c' is created.


2.4) On org 'b' run command:  
    `./org-start-node.sh` 
This starts network on node 'b'

2.5) On org 'c' run command:  
    `./org-start-node.sh`     
This starts network on node 'c'
    
2.6) To join org 'b' and 'c' to their bilateral channel run:  
    Org 'b':  
    `./org-join-org.sh c $IP3 b-c`  
    Org 'c':  
    `./org-join-org.sh b $IP2 b-c` 

This configures connectivity between orgs 'b' and 'c' and creates bilateral channel 'b-c' with this orgs joined
     