#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

export ARGS_PASSED=("${@}")
source "${BASEDIR}/../libs/libs.sh"

export RENEW_IMAGES=${RENEW_IMAGES:-true}
main() {

    local configDirPath="$(absDirPath "${ARGS_PASSED}")"
    configDirPath=${configDirPath:-${NETCONFPATH}}

    checkArgsPassed
    DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}

    tryNetworkCustomScript "${configDirPath}" "start.sh"

    local bootstrapOrgConfigFile=$(ls -1 "${configDirPath}" | grep -E "^bootstrap_.*_env|^org1_env")
    local bootstrapOrgConfigPath="${configDirPath}/${bootstrapOrgConfigFile}"

    if [ -z "${bootstrapOrgConfigFile}" ] && [ -z "${MAIN_ORG_FILE}" ]; then
        printInfo "${RED}No bootstrap_org_env or org1_env file found. Exiting...${NORMAL}" \
                  "Or set MAIN_ORG_FILE=/path/to/the/main/org/config/file"
        exit
    fi
    if [ -n "${MAIN_ORG_FILE}" ]; then
        bootstrapOrgConfigPath="${MAIN_ORG_FILE}"
        bootstrapOrgConfigFile=$(basename "${bootstrapOrgConfigPath}")
    fi


    printInfo   "Deploing network for [${DEPLOYMENT_TARGET}] target." \
                "\${DOCKER_REGISTRY}: [${DOCKER_REGISTRY}]" \
                "\${MULTIHOST}: [${MULTIHOST}]" \
                "Main org config: ${bootstrapOrgConfigPath}"

    sleep 2

    local restOrgsConfPathes=$(ls -1 "${configDirPath}"| grep -E "_env$" | grep -v "${bootstrapOrgConfigFile}"| xargs -I {} echo "${configDirPath}/{}")
    pushd "$BASEDIR/../../" >/dev/null
        cleanOrg "${bootstrapOrgConfigPath}"
        cleanNetwork "${restOrgsConfPathes}"

        deployOrg "${bootstrapOrgConfigPath}"
        export BOOTSTRAP_IP=${MY_IP} #TODO: refactor to common-test-env
        deployNetwork "${restOrgsConfPathes}"

        unsetActiveOrg
    popd >/dev/null
}


function cleanOrg() {
    local confPath="${@}"
    local org=$(getVarFromEnvFile ORG "${confPath}")
    local domain=$(getVarFromEnvFile DOMAIN "${confPath}")

    connectOrgMachine ${org} ${domain}
    printInfo "Cleaning org ${confPath}"
    ./clean.sh all
}

function deployOrg() {
    local confPath="${@}"
    local org=$(getVarFromEnvFile ORG "${confPath}")
    local domain=$(getVarFromEnvFile DOMAIN "${confPath}")

    connectOrgMachine ${org} ${domain}
    setSpecificEnvVars ${org} ${domain}

    printInfo "Deploy Fabric version: ${FABRIC_MAJOR_VERSION}" \
                  "Using config file: ${confPath}" \
                  "\${MY_IP}: ${MY_IP}" \
                  "\${BOOTSTRAP_IP}: ${BOOTSTRAP_IP}" \
                  "\${FABRIC_STARTER_HOME}: ${FABRIC_STARTER_HOME}"

    printInfo "Deploing org ${confPath}"
    NO_CLEAN=true ./deploy.sh "${confPath}"
}

function cleanNetwork() {
    local restOrgsConfPathes=${@}
    local confPath

    for confPath in ${restOrgsConfPathes[@]}; do
         cleanOrg "${confPath}"
    done
    printInfo "Cleaned up"
}

function deployNetwork() {
    local restOrgsConfPathes=${@}
    local confPath

    for confPath in ${restOrgsConfPathes[@]}; do
        deployOrg "${confPath}"
    done
    printInfo "Orgs deployed"
}

function tryNetworkCustomScript() {
    local configDirPath="${1}"
    local scriptName="${2}"

    if [ -f "${configDirPath}/${scriptName}" ]; then
        "${configDirPath}/${scriptName}"
        if [ $? != 0 ]; then
            printError "ERROR:${NORMAL} The ${BRIGHT}${GREEN}${configDirPath}/${scriptName}${NORMAL} script returned non-zero exit code."
            exit
        fi
    fi
}


main ${@}
