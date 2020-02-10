#!/usr/bin/env bash

[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
source ${BASEDIR}/libs.sh

runCLI=false && runAPI=false
declare -a FOLDERS

main () {
    selectFolders $@
    #echo "cli: $runCLI api: $runAPI"
    
    for SCRIIPT_FOLDER in "${FOLDERS[@]}"
    do
        export TEST_CHANNEL_NAME=$(getRandomChannelName)

        runTest ${BASEDIR}/${SCRIIPT_FOLDER}/create-channel.sh
        runTest ${BASEDIR}/verify/test-exist-channel.sh
        runTest ${BASEDIR}/verify/test-exist-channel.sh ${TEST_CHANNEL_NAME} ${ORG2}
        runTest ${BASEDIR}/${SCRIIPT_FOLDER}/create-channel.sh ${TEST_CHANNEL_NAME}"0" ${ORG2}
        runTest ${BASEDIR}/verify/test-exist-channel.sh ${TEST_CHANNEL_NAME}_ ${ORG1}
    done
}

function selectFolders() {
    for var in "$@"
    do
        [ "$var" = "cli" ] && runCLI=true
        [ "$var" = "api" ] || [ "$var" = "curl" ]  && runAPI=true
    done
    if ! "$runCLI"  &&  ! "$runAPI"; then runCLI=true; runAPI=true; fi
    
    if "${runCLI}"; then FOLDERS+=(cli); fi
    if "${runAPI}"; then FOLDERS+=(curl); fi
}

function runTest() {
    echo
    printYellow "Step: $((++step))"
    printLog "Step: ${step}"
    printLog "$@"
    eval "$@"
    printDbg "Step ${step}: exit code $?"
}


main $@


#SCRIIPT_FOLDER

#export TEST_CHANNEL_NAME=
#export DOMAIN=test.net
#source ./local-test-env.sh test.net sberbank vtb
#./curl/create-channel.sh
#./verify/test-exist-channel.sh
#./curl/add-org-to-channel.sh
