#!/usr/bin/env bash

export export DOCKER_COMPOSE_ARGS=" -f docker-compose.yaml -f docker-compose-couchdb.yaml -f https/docker-compose-generate-tls-certs.yaml -f https/docker-compose-https-ports.yaml -f docker-compose-ldap.yaml -f environments/dev/docker-compose-debug.yaml -f https/docker-compose-generate-tls-certs-debug.yaml"

cat > org1_env << END
export ORDERER_TYPE=SOLO
export ORDERER_WWW_PORT=79

export ORG=org1
export DOMAIN=example.com
export WWW_PORT=80
export API_PORT=4000
export PEER0_PORT=7051

export METRICS_PROVIDER_PORT=9090
export ORDERER_PORT=7050

export LDAP_PORT_HTTPS=6443
export LDAP_PORT_HTTP=6080
END

cat > org2_env << END
export ORDERER_TYPE=SOLO
export ORDERER_WWW_PORT=79

export ORG=org2
export DOMAIN=example.com
export WWW_PORT=81
export API_PORT=4001
export PEER0_PORT=8051

export ORDERER=false

export LDAP_PORT_HTTPS=6444
export LDAP_PORT_HTTP=6081
END


./main.sh org1 org2


