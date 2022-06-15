#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source "${BASEDIR}"/../libs/libs.sh


errorCode=${1}
expectedCode=${2}

printToLogAndToScreenBlue "\nChecking exit code..."

printResultAndSetExitCode "Exit code is OK: (0)" ${expectedCode} ${errorCode}
