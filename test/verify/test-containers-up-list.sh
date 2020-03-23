#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh

domain=${1}; shift
orgs=($@)

printToLogAndToScreenBlue "\nVerifing that all the test network containers ${DOMAIN} are up and running"

compareContainerListWithTemplate "${domain}" ${orgs[@]}

printResultAndSetExitCode "All the test network containers are up and running"
