#!/usr/bin/env bash

main() {
    export TEST_CHANNEL_NAME=${1:-${TEST_CHANNEL_NAME:? Channel name is required.}}
    
    export PEER_NAME=${PEER_NAME:-peer0}
    export API_NAME=${API_NAME:-api}
    export CLI_NAME=${CLI_NAME:-cli}
    
    export -f scenarioArgsParse
}


function scenarioArgsParse() {
    shift
    local args_req=${1}
    shift 2
    local args_passed=( "$@" )

    printDbg "Arguments passed: ${args_passed[@]}"
    set -f
    IFS=',' read -r -a args_required <<< "${args_req}"
    set +f

    printDbg "Arguments required: ${args_required[@]}"

    local num_args_required="${#args_required[@]}"
    local num_args_passed="${#args_passed[@]}"
    printDbg "scenarioArgsParse: args required: ${num_args_required} ${args_required[@]} args passed: ${num_args_passed} ${args_passed[@]}"
    
      if [ ${num_args_required} -gt ${num_args_passed} ];
      then
           printError "\nERROR: Number of args required (${num_args_required}) and args passed (${num_args_passed}) differs!"
           printYellow "The following args shoud be supplied: ${WHITE}${args_req}"
           exit 1
      fi
  

    
}

main $@