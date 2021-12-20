#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

export ARGS_PASSED=("$@")
source "${BASEDIR}/../libs/libs.sh"

export RENEW_IMAGES=${RENEW_IMAGES:-true}
main() {

    local dir="$(absDirPath "${@}")"

    checkArgsPassed
    DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}

    if [ -f "${dir}/start.sh" ]; then
    "${dir}/start.sh"
        if [ $? != 0 ]; then
            printError "ERROR:${NORMAL} The ${BRIGHT}${GREEN}${dir}/start.sh${NORMAL} script returned non-zero exit code."
            exit
        fi
    fi

    echo "Deploing network for [${DEPLOYMENT_TARGET}] target. Domain: $DOMAIN, Orgs: ${orgs[@]}"
    echo "\${DOCKER_REGISTRY} is set to: [${DOCKER_REGISTRY}]"
    echo "\${MULTIHOST} is set to: [${MULTIHOST}]"

    local org_conf_pathes=$(ls -1 "${dir}"| grep -E "_env$" | xargs -I {} echo "$(absDirPath "${dir}")/{}")

    pushd "$BASEDIR/../../" >/dev/null

      local org_no=1
      local ORG_IPS=''

      for path in ${org_conf_pathes[@]}; do
           org=$(getVarFromEnvFile ORG "${path}")
           #domain=$(getVarFromEnvFile DOMAIN "${path}")
           eval $(connectOrgMachine ${org}) #$domain)
           env | grep DOCKER
          ./clean.sh all
          eval "export $(genIP ${org_no} ${org})"
          ((org_no+=1))
      done
      echo "Cleaned up"

      for path in ${org_conf_pathes[@]}; do
          org=$(getVarFromEnvFile ORG "$path")
          eval $(connectOrgMachine "${org}")
          env | grep DOCKER
          echo "Deploy Fabric version: ${FABRIC_MAJOR_VERSION}"
          
          NO_CLEAN=true FABRIC_STARTER_HOME=$(getFabricStarterHome) ./deploy.sh "${path}"
      done
    unsetActiveOrg
    popd >/dev/null
}


function genIP() {
    local no=$1
    local org=$2
    
    echo "ORG${no}_IP=$(getOrgIp $org)"
}

main ${@}
