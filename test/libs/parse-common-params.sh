#!/usr/bin/env bash

main() {
    export TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME:? Channel name is required.}}
    
    export PEER_NAME=${PEER_NAME:-peer0}
    export API_NAME=${API_NAME:-api}
    export CLI_NAME=${CLI_NAME:-cli}
    
    export -f scenarioArgsParse
}


function scenarioArgsParse() {
    
    args_required=(${ARGS_REQUIRED[@]})
    args_passed=(${ARGS_PASSED[@]})
    
    local num_args_required="${#args_required[@]}"
    local num_args_passed="${#args_passed[@]}"
    
    printDbg "Required: ${num_args_required} ${args_required[@]}  Passed: ${num_args_passed} ${args_passed[@]} " >/dev/tty
    
    if [ ${num_args_required} -gt ${num_args_passed} ];
    then
        
        for argument in "${args_required[@]}"
        do
            arg_desc+="\"$(echo $argument | cut -d ':' -f 1)\" "
        done
        
        printError "\nERROR: Number of args required and args passed differs!"
        printYellow "The following args shoud be supplied: ${WHITE}${arg_desc}"
        exit 1
    fi
    
    local position=$(arrayStartIndex)
    
    for argument in "${args_required[@]}"
    do
        local varname=$(echo $argument | cut -d ':' -f 2)
        eval "export \"${varname}\"=\${ARGS_PASSED[$position]}"
        position=$(($position + 1))
    done
}

main $@