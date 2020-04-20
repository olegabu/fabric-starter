#!/usr/bin/env bash

#echo "Verify test-exit-code.sh: exit code: $?"

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh
#source "${BASEDIR}"/../libs/parse-common-params.sh $@

errorCode=${1}
expectedCode=${2}



printToLogAndToScreenBlue "\nChecking exit code..."

printResultAndSetExitCode "Exit code is OK: (0)" ${expectedCode} ${errorCode}
