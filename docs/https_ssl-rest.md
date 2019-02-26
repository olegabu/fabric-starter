## _Deprecated. Another approach will be used_ 

<a name="sslhttps"></a>
## SSL\Https connection to API

You can configure Fabric Starter to serve API requests and WebUI at `https://` endpoint.
If an organization has own SSL-certificate it can be used in its web\rest communications (see below).  

Otherwise a self-signed certificate will be generated with `openssl` during first run of the network. 
The certificate's attributes for the auto-generated certificate may be adjusted by environment variables. 


### Use existing organization's certificate:
In order to apply existing certificates:  

- copy the certificate and the private key files into `ssl-certs` folder  
OR
- specify the path to the folder with the certificate in *SSL_CERTS_PATH* environment variable  
Then
- rename the certificate file to `public.crt` 
- rename the private key file to `private.key`

Start node with the `docker-compose` as described in previous chapters 
but specify additional docker-compose _override_ file parameter: `-f docker-compose-ssl.yaml` 
(and exclude `-f ports.yaml` as ports area changed)  

```bash
docker-compose -f docker-compose.yaml -f docker-compose-ssl.yaml up
```

### Define properties for the auto-generated certificate

To adjust certificates's parameters export necessary variables before _up_ the node:

```bash 
export CERT_COUNTRY="US" CERT_STATE="N/A" CERT_ORG="$ORG.$DOMAIN" CERT_ORGANIZATIONAL_UNIT="Hyperledger Fabric Blockchain" CERT_COMMON_NAME="Fabric-Starter-Rest-API"
```

If you use `network-create.sh` scripts export DOCKER_COMPOSE_ARGS variable 
```bash 
${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f couchdb.yaml -f multihost.yaml -f docker-compose-ssl.yaml}
```
