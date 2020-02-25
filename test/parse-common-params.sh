#!/usr/bin/env bash

main() {
    export TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME:? Channel name is required.}}
    # export active org
    export ORG=${2:-${ORG1:-org1}}
    
    export PEER_NAME=${PEER_NAME:-peer0}
    export API_NAME=${API_NAME:-api}
    
    export -f scenarioArgsParse
}


function scenarioArgsParse() {
    local num_args_required="${#ARGS_REQUIRED[@]}"
    local num_args_passed="${#ARGS_PASSED[@]}"
    
    if [ ${num_args_required} != ${num_args_passed} ];
    then
        
        for argument in "${ARGS_REQUIRED[@]}"
        do
            arg_desc+="\"$(echo $argument | cut -d ':' -f 1)\" "
        done
        
        printError "\nERROR: Number of args required and args passed differs!"
        printUsage \
        "The following args shoud b e supplied: ${WHITE}${arg_desc}" \
        "run_scenario.sh cli,api organization1 organization2"
        
        exit 1
    fi
    
    local position=$(arrayStartIndex)
    
    for argument in "${ARGS_REQUIRED[@]}"
    do
        local varname=$(echo $argument | cut -d ':' -f 2)
        eval "export \"${varname}\"=\${ARGS_PASSED[$position]}"
        position=$(($position + 1))
    done
}
main $@