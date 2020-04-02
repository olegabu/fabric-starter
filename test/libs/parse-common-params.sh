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
    # printDbg "Arg1: _${args_required[0]}_"
    # printDbg "Arg2: _${args_required[1]}_"
    # printDbg "Arg3: _${args_required[2]}_"

    # printDbg "Argp1: _${args_passed[0]}_"
    # printDbg "Argp2: _${args_passed[1]}_"
    # printDbg "Argp3: _${args_passed[2]}_"

    
    #  if [ ${num_args_required} -gt ${num_args_passed} ];
    #  then

    #      for argument in "${args_required[@]}"
    #      do
    #          arg_desc+="\"$(echo $argument | cut -d ':' -f 1)\" "
    #      done

    #      printError "\nERROR: Number of args required and args passed differs!"
    #      printYellow "The following args shoud be supplied: ${WHITE}${arg_desc}"
    #      exit 1
    #  fi

    #  local position=$(arrayStartIndex)

    #  for argument in "${args_required[@]}"
    #  do

    #      local varname=$(echo $argument | cut -d ':' -f 2)
    #      eval "export \"${varname}\"=\${args_passed[$position]}"
    #      position=$(($position + 1))
    #  done

      local position=$(arrayStartIndex)
      local arg_desc
      local varname  
        
        for argument in "${args_required[@]}"
        do
            set -f
            IFS=':'
            argument=($argument)
            set +f

            arg_desc+=${argument[$(arrayStartIndex)]}
            varname=${argument[(($(arrayStartIndex) + 1))]}    
            #arg_desc+="\"$(echo $argument | cut -d ':' -f 1)\" "
            #varname=$(echo $argument | cut -d ':' -f 2)
            eval "export \"${varname}\"=\${args_passed[$position]}"
            position=$(($position + 1))
            
        done

      if [ ${num_args_required} -gt ${num_args_passed} ];
      then
           printError "\nERROR: Number of args required and args passed differs!"
           printYellow "The following args shoud be supplied: ${WHITE}${arg_desc}"
           exit 1
      fi
    
    
    # for argument in "${args_required[@]}"
    # do
	
    # done





    # echo "Fabric test interface: $interface_types"
    # echo "First organization: $org1"
    # echo "Second organization: $org2"
    
}

main $@