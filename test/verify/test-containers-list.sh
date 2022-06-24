#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

containersType=${1}
activeOrg=${2}
containersList=${@:3}

printToLogAndToScreenBlue "\nCheck containers running: [${containersList}] on [${activeOrg}]"
checkContainersExist ${containersType} ${activeOrg} ${containersList}

printResultAndSetExitCode "OK: [${containersList}] containers are running"
