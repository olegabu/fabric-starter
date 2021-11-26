#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

export ARGS_PASSED=("$@")
source ../libs/libs.sh
export orgs=("$@")
main() {
    checkArgsPassed

    DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}

    echo "Deploing network for [${DEPLOYMENT_TARGET}] target. Domain: $DOMAIN, Orgs: ${orgs[@]}"
    echo "\${DOCKER_REGISTRY} is set to: [${DOCKER_REGISTRY}]"
    echo "\${MULTIHOST} is set to: [${MULTIHOST}]"

    export DOCKER_COMPOSE_ARGS="-f docker-compose.yaml -f docker-compose-couchdb.yaml -f docker-compose-ports.yaml "

    pushd ../../ >/dev/null
    createOrgEnvFiles ${@}

      for org in ${orgs[@]}; do
           eval $(connectOrgMachine "${org}")
           env | grep DOCKER
          ./clean.sh all
      done
      echo "Cleaned up"

      for org in ${orgs[@]}; do
          eval $(connectOrgMachine "${org}")
          env | grep DOCKER
	  if [ ${FABRIC_MAJOR_VERSION} -ne 1 ]; then
            NO_CLEAN=true ./deploy-2x.sh ${org}
	  else
	    NO_CLEAN=true ./deploy.sh ${org}
	  fi
      done
    unsetActiveOrg

    popd >/dev/null
}

function envSubstWithDefualts() {
    local file

    file="${1}"
    xargs -a "${file}" -I{} -d'\n' bash -c 'echo "{}"'
}


function createOrgEnvFiles() {

  local first_org=${1}
  local bootstrap_ip_val=$(getOrgIp "${first_org}")
  local bootstrap_api_port_val=4000
  local bootstrap_service_url='http'
  local orderer_type='SOLO'
  local orderer_port=7050
  local orderer_www_port=79
  local orderer_name='orderer'
  local api_port=4000
  local www_port=80
  local sdk_port=8080
  local tls_ca_port=7055
  local ca_port=7054
  local peer0_port=7051
  local external_communication_port=443
  local ldap_port_http=6080
  local ldap_port_https=6433
  local orderer_general_listenport=7050

  for org in ${@}; do
    local result
    local fabric_starter_home
    local bootstrap_ip="${bootstrap_ip_val}"
    local bootstrap_api_port="${bootstrap_api_port_val}"

    fabric_starter_home=$(getFabricStarterHome "${org}")

    if [[ "${org}" == "${first_org}" ]]; then
        bootstrap_ip=''
        bootstrap_api_port=''
    fi

    result=$(ORG=${org} \
    DOMAIN=${DOMAIN} \
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
    SDK_PORT=${sdk_port} \
    TLS_CA_PORT=${tls_ca_port} \
    PEER0_PORT=${peer0_port} \
    EXTERNAL_COMMUNICATION_PORT=${external_communication_port} \
    LDAP_PORT_HTTP=${ldap_port_http} \
    LDAP_PORT_HTTPS=${ldap_port_https} \
    FABRIC_STARTER_HOME=${fabric_starter_home} \
    ORDERER_GENERAL_LISTENPORT=${orderer_general_listenport} \
    envSubstWithDefualts "org_env_sample"  > "${org}"_enva)

    if [ -n ${DONT_INCREASE_PORTS} ]; then
        api_port=$((api_port + 1))
        www_port=$((www_port + 1))
        ca_port=$((ca_port + 100))
        sdk_port=$((sdk_port + 1000))
        tls_ca_port=$((tls_ca_port + 1000))
        peer0_port=$((peer0_port + 1000))
        external_communication_port=$((external_communication_port+1000))
        ldap_port_http=$((ldap_port_http + 100))
        ldap_port_https=$((ldap_port_https + 100))
    fi


  done
 }

 main ${@}
