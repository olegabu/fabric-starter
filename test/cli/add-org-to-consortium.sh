#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs.sh
source "${BASEDIR}"/../parse-common-params.sh $@

org2_=$2

printToLogAndToScreenCyan "\nAdd ${org2_} to the default consortium..."

setCurrentActiveOrg ${ORG}

runInFabricDir ./consortium-add-org.sh ${org2_}

printResultAndSetExitCode "Organization ${org2_} added to the default consortium"