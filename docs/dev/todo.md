

### Configtx

- [ ] Join configtx-template.yaml(used in container-peer.sh) and configtx-template.dynamic.yaml 
    (used in container-orderer.yaml)
- [ ] Introduce a `version` param to include corrspondednt snippets to resulting configtx.yaml     

### Chaincodes
- [ ] Pre-installed chaincodes depend on shim version and the engine version. This may effect in future incompatibilities.
    Need an approach to maintain this. Temporary solution is - folder "2x".
---
- [ ] The volume /opt/chaincode is assigned to CHAINCODE_HOME, but also copied to the image 
    in the Dockerfile thus they are clashes. Need to test it to avoid future bugs.
    
- [ ] Need to orginize chaincodes by versions (as fabric-shim is of different versions),
      but do we need to extract common business-logic (to prevent duplication) ?  