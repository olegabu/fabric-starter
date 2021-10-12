#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

export ARGS_PASSED=("$@")
source ../libs/libs.sh
main() {
checkArgsPassed

orgs=${@}
DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}

echo "Deploing network for [${DEPLOYMENT_TARGET}] target. Domain: $DOMAIN, Orgs: ${orgs[@]}"
echo "\${DOCKER_REGISTRY} is set to: [${DOCKER_REGISTRY}]"
echo "\${MULTIHOST} is set to: [${MULTIHOST}]"
#sleep 2

export DOCKER_C_ARGS="-f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-ports.yaml "


         pushd ../../ >/dev/null
         createOrgEnvFiles ${@}


#exit
for org in ${@}; do
        eval $(docker-machine env ${org}.${DOMAIN})
        export DOCKER_COMPOSE_ARGS="${DOCKER_C_ARGS}"
        ./deploy.sh ${org}
done
        eval $(docker-machine env --unset)
        popd >/dev/null
}

function createOrgEnvFiles() {
#  local org="${1:?Org name is required}"
#  local org1="${2:?First org name is required}"
#  local bootstrap_ip="${3:?bootstrap_ip is required}"
    local first_org
    local bootstrap_ip_val
    local bootstrap_api_port_val
    local orderer_type
    local orderer_port
    local orderer_www_port
    local orderer_name
    local api_port
    local www_port
    local ca_port
    local peer0_port
    local ldap_port_http
    local ldap_port_https

   first_org=${1}
   bootstrap_ip_val=$(getOrgIp "${first_org}")
   bootstrap_api_port_val=4000
   bootstrap_service_url='http'
   orderer_type='RAFT1'
   orderer_port=7050
   orderer_www_port=79
   orderer_name='orderer'
   api_port=4000
   www_port=80
   ca_port=7054
   peer0_port=7051
   ldap_port_http=6080
   ldap_port_https=6433
   
  echo "BEFORE FOR org: ${org} ip: ${bootstrap_ip_val} api: ${bootstrap_api_port_val} first: ${first_org}"
  for org in ${@}; do
    local bootstrap_ip="${bootstrap_ip_val}"
    local bootstrap_api_port="${bootstrap_api_port_val}"
    echo "BEFORE IF org: ${org} ip: ${bootstrap_ip_val} api: ${bootstrap_api_port_val} first: ${first_org}"
    if [[ "${org}" == "${first_org}" ]]; then
        echo "FIRST ORG"
        bootstrap_ip=''
        bootstrap_api_port=''
        echo "INSIDE IF org: ${org} ip: ${bootstrap_ip} api: ${bootstrap_api_port} first: ${first_org}"
    fi
        echo "OUTSIDE IF org: ${org} ip: ${bootstrap_ip} api: ${bootstrap_api_port} first: ${first_org}"

            ORG=${org} DOMAIN=${DOMAIN} \
            MY_IP=$(getOrgIp ${org}) \
            API_PORT=${api_port} \
            WWW_PORT=${www_port} \
            BOOTSTRAP_IP=${bootstrap_ip} \
            BOOTSTRAP_API_PORT=${bootstrap_api_port} \
            BOOTSTRAP_SERVICE_URL=${bootstrap_service_url} \
            ORDERER_TYPE=${orderer_type} \
            ORDERER_PORT=${orderer_port} \
            ORDERER_WWW_PORT=${orderer_www_port} \
            ORDERER_NAME=${orderer_name} \
            CA_PORT=${ca_port} \
            PEER0_PORT=${peer0_port} \
            LDAP_PORT_HTTP=${ldap_port_http} \
            LDAP_PORT_HTTPS=${ldap_port_https} \
            FABRIC_STARTER_HOME=$(docker-machine ssh ${org}.${DOMAIN} pwd) \
            envsubst < test/resources/org_env/org_env > "${org}"_env
        if [[ "${DEPLOYMENT_TARGET}" == "local" ]]; then
            api_port=$((api_port + 1))
            www_port=$((www_port + 1))
            orderer_www_port=$((orderer_www_port - 1))
        fi
            ca_port=$((ca_port + 1))
            orderer_port=$((orderer_port + 1000))
            peer0_port=$((peer0_port + 1000))
            ldap_port_http=$((ldap_port_http + 100))
            ldap_port_https=$((ldap_port_https + 100))
  done
 }

 main ${@}