## _Deprecated. Another approach will be used_ 

<a name="sslhttps"></a>
## SSL\Https connection to API

You can configure Fabric Starter to serve API requests and WebUI at `https://` endpoint.
If an organization has own TLS-certificate it can be used in the https communications (see below).  

Otherwise a self-signed certificate will be generated with `openssl` during first startup of the network. 
The certificate's attributes for the auto-generated certificate may be adjusted using environment variables. 


### Use existing organization's certificate:
In order to apply existing certificates:  

- copy the certificate and the private key files into `ssl/certs` folder   
OR
- specify the path to the folder with the certificate in *SSL_CERTS_ROOT_PATH* environment variable
- Create subpath for each organization #ORG.$DOMAIN/
- Put `public.crt` and `private.key` into the corresponded organization's repository
NOTE:
- the certificate file has to be named `public.crt` 
- the private key file has to be named `private.key`

Start node with the `docker-compose` as described in previous chapters 
but specify additional docker-compose _override_ file parameters: 
`-f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-https-ports.yaml` 
(and exclude `-f docker-compose-ports.yaml` as ports mapping is changed)  

```bash
docker-compose -f docker-compose.yaml -f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-https-ports.yaml up
```

### Define properties for the auto-generated certificate

To adjust certificates's parameters export necessary variables before _up_ the node:

```bash 
export CERT_COUNTRY="US" CERT_STATE="N/A" CERT_ORG="$ORG.$DOMAIN" CERT_ORGANIZATIONAL_UNIT="Hyperledger Fabric Blockchain" CERT_COMMON_NAME="Fabric-Starter-Rest-API"
```

If you use `network-create.sh` scripts export DOCKER_COMPOSE_ARGS variable 
```bash 
${DOCKER_COMPOSE_ARGS:- -f docker-compose.yaml -f docker-compose-couchdb.yaml -f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-https-ports.yaml}
```
