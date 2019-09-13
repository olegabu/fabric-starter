# LDAP Directories

By default Hyperledger Fabric Certification Authority center is used to manage user management and membership.
The CA's SDK or CLI tools (fabric-ca-client) can be used to enroll users from the name of *admin* account.

In order to use LDAP server CA fabric-starter reconfigures CA and link it to an LDAP server.

There are two options for LDAP connection:
- Use docker-based LDAP container deployed along with current organisation blockchain containers
- Use external LDAP server (TBD)


## Use docker-based LDAP container

Docker based LDAP server is used from *osixia/openldap* docker image. See https://github.com/osixia/docker-openldap

Set environment variable *LDAP_ENABLED=true* before generating peer configuration. Fabric-starter scripts will automatically
construct *LDAP_BASE_DN* from the *DOMAIN* environment variable and generate Fabric-CA's server configuration file:

```bash
#export DOMAIN=xxx
export LDAP_ENABLED=true
```

If you need to have different LDAP Base Distinguish Name you can export it explicitly:
```bash
 export LDAP_BASE_DN=dc=example,dc=com
 ```

You can also configure admin's password in the *.env* file in *ENROLL_SECRET* variable.

Generate the peer configuration as usually:
```bash
./generate-peer.sh
 ```


Start Ldap service and Ldap PHP Admin application in docker containers:
 ```bash
 docker-compose -f docker-compose-ldap.yaml up
  ```

Ldap PHP Admin now is available at http://localhost:6080.  
Default login name for ldap-service is **cn=admin,dc=example,dc=com**, password **adminpw** (or as specified in the *.env* file)

To add new users to ldap directories use **Create new entry here** item in the domain tree. Use **Courier Mail: Account** template.

Start peer as usual:
 ```bash
 docker-compose up
  ```


## Use external LDAP server

As the first step using external LDAP server involves same setting of *LDAP_ENABLED* and *LDAP_BASE_DN* variables and putting certificates in places.

But for particular LDAP server special attribute conversion rules may be required to be configured
so we have to check the deployment for each LDAP server separatley


