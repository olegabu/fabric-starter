#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

export ARGS_PASSED=("${@}")
source "${BASEDIR}/../libs/libs.sh"

export RENEW_IMAGES=${RENEW_IMAGES:-true}
main() {

    local config_dir_path="$(absDirPath "${ARGS_PASSED}")"

    checkArgsPassed
    DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}
    tryNetworkCustomScript "${config_dir_path}" "start.sh"

    printInfo   "Deploing network for [${DEPLOYMENT_TARGET}] target." \
                "\${DOCKER_REGISTRY}: [${DOCKER_REGISTRY}]" \
                "\${MULTIHOST}: [${MULTIHOST}]"
    sleep 2

    local bootstrap_org_config_file=$(ls -1 "${config_dir_path}" | grep -E "^bootstrap_.*_env")
    local bootstrap_org_config_path="${config_dir_path}/${bootstrap_org_config_file}"
    local org_conf_pathes=$(ls -1 "${config_dir_path}"| grep -E "_env$" | grep -v "${bootstrap_org_config_file}"| xargs -I {} echo "${config_dir_path}/{}")

    pushd "$BASEDIR/../../" >/dev/null
        cleanOrg "${bootstrap_org_config_path}"
        cleanNetwork "${org_conf_pathes}"

        deployOrg "${bootstrap_org_config_path}"
        export BOOTSTRAP_IP=${MY_IP} #TODO: refactor to common-test-env
        deployNetwork "${org_conf_pathes}"

        unsetActiveOrg
    popd >/dev/null
}


function cleanOrg() {
    local conf_path="${@}"
    local org=$(getVarFromEnvFile ORG "${conf_path}")
    local domain=$(getVarFromEnvFile DOMAIN "${conf_path}")

    connectOrgMachine ${org} ${domain}
    printInfo "Cleaning org ${conf_path}"
    ./clean.sh all
}

function deployOrg() {
    local conf_path="${@}"
    local org=$(getVarFromEnvFile ORG "${conf_path}")
    local domain=$(getVarFromEnvFile DOMAIN "${conf_path}")

    connectOrgMachine ${org} ${domain}
    setSpecificEnvVars ${org} ${domain}

    printInfo "Deploy Fabric version: ${FABRIC_MAJOR_VERSION}" \
                  "Using config file: ${conf_path}" \
                  "\${MY_IP}: ${MY_IP}" \
                  "\${BOOTSTRAP_IP}: ${BOOTSTRAP_IP}" \
                  "\${FABRIC_STARTER_HOME}: ${FABRIC_STARTER_HOME}"

    printInfo "Deploing org ${conf_path}"
    NO_CLEAN=true ./deploy.sh "${conf_path}"
}

function cleanNetwork() {
    local org_conf_pathes=${@}
    local conf_path

    for conf_path in ${org_conf_pathes[@]}; do
         cleanOrg "${conf_path}"
    done
    printInfo "Cleaned up"
}

function deployNetwork() {
    local org_conf_pathes=${@}
    local conf_path

    for conf_path in ${org_conf_pathes[@]}; do
        deployOrg "${conf_path}"
    done
    printInfo "Orgs deployed"
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
