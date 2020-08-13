#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

source "${BASEDIR}"/../libs/libs.sh

org=${2}

printToLogAndToScreenCyan "\nAdd [${org}] to the default consortium..."

setCurrentActiveOrg ${org}
runInFabricDir ./consortium-add-org.sh ${org}

printResultAndSetExitCode "Organization [${org}] added to the default consortium"
