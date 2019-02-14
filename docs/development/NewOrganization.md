# Add new organization 

In order to add new organization to the blockchain network several steps 
need to be accomplished:

- New organization is to be verified by an commonly available method to be the one it claims. 
It might be e.g. the following options:
    - OAuth2 or other authentication protocols
    - external trusted CA   
    - IBM's Identity or other Sovereign Identity solution  
- The organization's IP address need to be propagated to be available for the other orgs. 
The options are:
    - central DNS server
    - decentralized DNS service with DNS-server at each node
    - adjusting /etc/hosts (mapped to) each container at each node
- Configuration Update Transaction for the consortium need to be formed and signed 
by MAJORITY of the existing organizations' Admins (or according to the configured policy)               

[Organizations Registry Service](OrgsRegistryService/OrgsRegistryService.md) 
tracks the organizations information and IP propagation.

[IdentityVerificationService] is to be done.   

[ConfigUpdate Transaction signing cycle] is to be implemented in the Admin Dashboard webapp 
with support in the _Organizations Registry Service_.       