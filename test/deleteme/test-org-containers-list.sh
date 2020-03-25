#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

domain=${1}
org=${2}
orgs_csv=${3}

printToLogAndToScreenBlue "\nVerifing that all the test network containers ${DOMAIN} are up and running"

compareOrgContainersLists ${org} ${DOMAIN} ${orgs_csv}

printResultAndSetExitCode "All the test network containers are up and running"


