# LDAP Directories

Hyperledger Fabric has two options for user management:
- Fabric CA - one of the component of the Hyperledger Fabric itself
    - in this scenario users can be added using Fabric CA CLI tools or Fabric CA SDK
- LDAP directory which the Fabric CA server connects to
    - in this scenario Fabric CA use the LDAP as the user registry, and the LDAP server facilities are used to manage users


There are two options for deployment LDAP-based  :
- Use docker-based LDAP server from *osixia/openldap* (https://github.com/osixia/docker-openldap)
- Use external LDAP server 


## Use *osixia/openldap* LDAP server in docker

LDAP server is deployed by default if you use _deploy-2x.sh_
The environment variable *LDAP_ENABLED* is then set to true, *LDAP_BASE_DN* is constructed automatically from the *DOMAIN* environment variable.

If you need to have a different LDAP Base Distinguish Name you can export it explicitly (or specify it in _org_env_):
```bash
 export LDAP_BASE_DN=dc=example,dc=com
 ```

The _admin_'s password configured in the *.env* or *org_env* files in *ENROLL_SECRET* variable is also applied to ldap directory.

Ldap PHP Admin is also deployed and is available by default at *https://server:6443*.

Default login name for ldap-service is **cn=admin,dc=example,dc=com**, password **adminpw** (or _ENROLL_SECRET_ from the *.env* or *org_env* file)

To add new users to ldap directories use **Create new entry here** item in the domain tree. Use **Courier Mail: Account** template.
Pay attention to *Common Name* field which is then used by users to login.


## Use external LDAP server

As the first step using external LDAP server involves same setting of *LDAP_ENABLED* and *LDAP_BASE_DN* variables and putting certificates in places.

But for particular LDAP server special attribute conversion rules may be required to be configured
so we have to check the deployment for each LDAP server separatley

## Development mode

When developing you can avoid using ldap server: 
    Export LDAP_ENABLED=<empty> or export DEV_MODE=1 to skip LDAP, before starting node by deploy-2x.sh.   

Fabric CA server will be used then, and the rest server will enroll users automatically at the first login.
