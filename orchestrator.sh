#!/usr/bin/env bash

cat > org1_env << END
ORG=org1
DOMAIN=sber-example.com
WWW_PORT=80
API_PORT=4000
PEER0_PORT=7051
LDAP_PORT_HTTP=6080

ORDERER=true
END

cat > org2_env << END
ORG=org2
DOMAIN=sber-example.com
WWW_PORT=81
API_PORT=4001
PEER0_PORT=8051
LDAP_PORT_HTTP=6081

ORDERER=false
END


./main.sh org1 org2


