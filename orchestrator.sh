#!/usr/bin/env bash

cat > org1_env << END
export FABRIC_VERSION=1.4.3
export FABRIC_STARTER_VERSION=baas-test
export ORG=org1
export DOMAIN=example.com
export WWW_PORT=80
export API_PORT=4000
export PEER0_PORT=7051

export ORDERER=true
export METRICS_PROVIDER_PORT=9090
export ORDERER_PORT=7050

#export LDAP_ENABLED=true
export LDAP_PORT_HTTPS=6443
export LDAP_PORT_HTTP=6080
export LDAPADMIN_HTTPS=true
END

cat > org2_env << END
export FABRIC_VERSION=1.4.3
export FABRIC_STARTER_VERSION=baas-test
export ORG=org2
export DOMAIN=example.com
export WWW_PORT=81
export API_PORT=4001
export PEER0_PORT=8051

export ORDERER=false

export LDAP_ENABLED=false
export LDAP_PORT_HTTPS=6444
export LDAP_PORT_HTTP=6081
export LDAPADMIN_HTTPS=false
END


./main.sh org1 org2


