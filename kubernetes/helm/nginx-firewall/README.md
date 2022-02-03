
See [EnterpriseDeployment](../../tech/deployment/EnterpriseDeployment.pdf) for deployment structure.

1. To set peers and orderers ports in cluster and on external orgs to 7051, 7050 respectively set values for 
```yaml
peerPort: 7051
ordererPort: 7050
externalOrgs.peerPort: 7051
externalOrgs.ordererPort: 7050

edge.peerPort: 443
edge.ordererPort: 443
```

1. Provide internal cluster domain (e.g. kubernetes default domain):
```yaml
cluster.domain: default 
```


1. Update ../node-deploy/external-hosts.yaml and add external organizations:
```yaml
externalHosts:
  - peer: peer0-org2.example.com
    orderer: orderer.example-org2.com
    ip: 192.168.1.1 
```

1. Generate **nginx.conf**:
```bash
helm template nginx . -f ../node-deploy/values.yaml -f values.yaml -f ../node-deploy/external-hosts.yaml --debug 
```

1. Exract generated config from output. Apply it to firewall nginx instance as **nginx.conf**. 