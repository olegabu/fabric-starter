#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

export ARGS_PASSED=("$@")
source "${BASEDIR}/../libs/libs.sh"

export RENEW_IMAGES=${RENEW_IMAGES:-true}
main() {

    local config_dir_path="$(absDirPath "${ARGS_PASSED}")"
    local org
    local domain
    local path

    checkArgsPassed
    DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}
    # run networkcustom script
    tryNetworkCustomScript "${config_dir_path}" "start.sh"

    echo "Deploing network for [${DEPLOYMENT_TARGET}] target. Domain: $DOMAIN, Orgs: ${orgs[@]}"
    echo "\${DOCKER_REGISTRY} is set to: [${DOCKER_REGISTRY}]"
    echo "\${MULTIHOST} is set to: [${MULTIHOST}]"

    local bootstrap_org_config_file=$(ls -1 "${config_dir_path}" | grep -E "^bootstrap_.*_env")
    local bootstrap_org_config_path="${config_dir_path}/${bootstrap_org_config_file}"
    local org_conf_pathes=$(ls -1 "${config_dir_path}"| grep -E "_env$" | grep -v "${bootstrap_org_config_file}"| xargs -I {} echo "${config_dir_path}/{}")

    pushd "$BASEDIR/../../" >/dev/null

      cleanOrg "${bootstrap_org_config_path}"

      for path in ${org_conf_pathes[@]}; do
           cleanOrg "${path}"
      done
      info "Cleaned up"

      deployOrg "${bootstrap_org_config_path}"
      export BOOTSTRAP_IP=${MY_IP} #TODO: refactor to common-test-env

      echo "Network bootstrap address: ${BOOTSTRAP_IP}"

      for path in ${org_conf_pathes[@]}; do
          deployOrg "${path}"
      done
      info "Orgs deployed"


      unsetActiveOrg
    popd >/dev/null
}

function cleanOrg() {
           local path="${@}"
           local org=$(getVarFromEnvFile ORG "${path}")
           local domain=$(getVarFromEnvFile DOMAIN "${path}")

           eval $(connectOrgMachine ${org} ${domain})
          ./clean.sh all
}

function deployOrg() {
           local path="${@}"
           local org=$(getVarFromEnvFile ORG "${path}")
           local domain=$(getVarFromEnvFile DOMAIN "${path}")

           eval $(connectOrgMachine ${org})
           echo "Deploy Fabric version: ${FABRIC_MAJOR_VERSION}"
           echo "Using config file: $path"

           setSpecificEnvVars $org $domain

           info "MY_IP: ${MY_IP}"
           info "NETWORK_BOOTSTRAP_IP: ${NETWORK_BOOTSTRAP_IP}"
           info "FABRIC_STARTER_HOME: ${FABRIC_STARTER_HOME}"

           NO_CLEAN=true ./deploy.sh "${path}"
}

function tryNetworkCustomScript() {
    local config_dir_path="${1}"
    local script_name="${2}"

    if [ -f "${config_dir_path}/${script_name}" ]; then
        "${config_dir_path}/${script_name}"
        if [ $? != 0 ]; then
            printError "ERROR:${NORMAL} The ${BRIGHT}${GREEN}${config_dir_path}/${script_name}${NORMAL} script returned non-zero exit code."
            exit
        fi
    fi
}

main ${@}
