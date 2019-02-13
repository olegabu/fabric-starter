
# Organizations Registry Service


It's planned to have special channel `OrgsRegistryService` which will: 
- store the registry information about all channels (IP, address, contact person, phone, etc)
- have the `OrgsRegistryServiceChaincode` assigned to it which implements the functionality   


The `OrgsRegistryServiceChaincode` is now planned to be implemented as a Fabric's system chaincode
which is installed as plugin, it has access to the peer container filesystem and therefore 
to the mapped _`/etc/hosts`_ file and so is able to modify it. 
Having same file is mapped to all other containers so all containers on the node will have 
resolving information instantly.     

The other option currently being discussed is to have DNS service (dnsmasq) 
on the host and update it's information by the chaincode.   

![Overview Diagram](OrgsRegistryServiceOverviewDiagram.png)




### Implementation notes:

- This chaincode has to have the endorsement policy set to ALL
