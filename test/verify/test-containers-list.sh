#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


activeOrg=${1}
orgDomain=${2}
shift; shift
containersList=${@}

printToLogAndToScreenBlue "\nCheck containers running: [${containersList}] on [${orgDomain}]"

checkContainersExist ${activeOrg} ${orgDomain} ${containersList}

printResultAndSetExitCode "OK: [${containersList}] containers are running"


