#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


domain=${1}
org=${2}
orgs_csv=${3}
positive_filter=${4:-"true"}
negative_filter=${5:-"dev-peer0"}

printToLogAndToScreenBlue "\nVerifing that all the test network containers ${DOMAIN} are up and running"

#only running containers (true), not chaincode containers (dec-peer0)
compareContainersLists ${org} ${DOMAIN} ${orgs_csv} "${positive_filter}" "${negative_filter}"

printResultAndSetExitCode "All the test network containers are up and running"


