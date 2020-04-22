 #!/usr/bin/env bash

IFS='[]'

main() {
    
 
    declare -a RESULTS
    stepNumber=
    rowSeparator='-|-|-|-'
    VERIFY_SCRIPT_FOLDER='verify'
    
    runTestScenario $*
}



function runTestScenario() {
    local interfaceTypes
    local scenarioArgs

#printDbg "runTestScenario: 1:$1 2:$2 3:$3 4:$4 5:$5 6:$6 7:$7"

    checkArgsPassed $@

    interfaceTypes=${4}
    shift 2
    scenarioArgs=$@

    unset IFS

    initResultsTable
    
    IFS=',' read -r -a INTERFACE_TYPES <<< "${interfaceTypes}"
    
    for SCRIPT_FOLDER in "${INTERFACE_TYPES[@]}"; do
        
        printYellowBox "Running ${SCRIPT_FOLDER} tests"
        addTableRowSeparator
        pushd ${TEST_ROOT_DIR}/${SCRIPT_FOLDER}/ >/dev/null
        SCENARIO ${scenarioArgs} # ${TEST_CHANNEL_NAME} ${TEST_CHAINCODE_NAME}
        popd >/dev/null
    done
    printTestResultTable
}


function initResultsTable() {
    
    RESULTS+=("STEP|TEST NAME|RESULT|TIME ELAPSED (s)")
    START_TIME=$(LC_TIME="en_US.UTF-8" date)
}


function addTableRowSeparator() {
    RESULTS+=("${rowSeparator}")
}


function getMaxTextLength() {
    local textLength=10
    local length
    
    for line_n in "${RESULTS[@]}"; do
        local line="$(echo ${line_n} | cut -d '|' -f 2)"
        local length=$(expr length "${line}")
        if [ "${length}" -gt "${textLength}" ]; then
            textLength=${length}
        fi
    done
    echo ${textLength}
}


function printLogStepHeader() {
    
    printLog "${BRIGHT}${WHITE}---------------------------${NORMAL}"
    printLog "${BRIGHT}${WHITE}Step: ${1}_${2} ${3}${NORMAL}"
    printLog "${BRIGHT}${WHITE}---------------------------${NORMAL}"
    
}


function printTestResultTable() {
    END_TIME=$(LC_TIME="en_US.UTF-8" date)
    
    echo -e "\n\n"
    
    local textlength=$(getMaxTextLength)
    
    local l1=10
    local l2=$((textlength + 5))
    local l3=10
    local l4=10
    
    local separator=$(printNSymbols '-' ${l1})"|"$(printNSymbols '-' ${l2})"|"$(printNSymbols '-' ${l3})"|"$(printNSymbols '-' ${l4})
    
    local total_errors=0
    local tests_run=0
    
    for result in "${RESULTS[@]}"; do
        if [ "${result}" = "-|-|-|-" ]; then result=${separator}; fi
        local test_step="$(echo ${result} | cut -d '|' -f 1)"
        local test_name="$(echo ${result} | cut -d '|' -f 2)"
        local exit_code="$(echo ${result} | cut -d '|' -f 3)"
        local elapsed_time="$(echo ${result} | cut -d '|' -f 4)"
        
        if [ "${exit_code}" = "0" ]; then
            tests_run=$(($tests_run + 1))
            total_time=$(awk "BEGIN{print ${total_time} + ${elapsed_time}}")
            exit_code="${BRIGHT}${GREEN}OK:  (${exit_code})${NORMAL}"
            
            elif [[ ! ${exit_code} =~ ^[0-9]+$ ]]; then
            :
        else
            exit_code="${BRIGHT}${RED}ERR: (${exit_code})${NORMAL}"
            total_errors=$(($total_errors + 1))
            tests_run=$(($tests_run + 1))
            total_time=$(awk "BEGIN{print ${total_time} + ${elapsed_time}}")
        fi
        IFS='~'
        timing=$(printPaddingSpaces "${exit_code}" "${elapsed_time}" ${l3})
        
        printf '%-'${l1}'s %-'${l2}'s %-'${l3}'s %-'${l4}'s\n' "${test_step}" "${test_name}" "${exit_code}" "${timing}"
    done
    echo ${separator//|/ }
    
    printYellow "Start time: ${WHITE}${START_TIME}${YELLOW}, End time: ${WHITE}${END_TIME}${YELLOW}"
    
    if [ "${total_errors}" = 0 ]; then
        printYellow "Total tests run: ${WHITE}${tests_run}${YELLOW} \nTotal tests runtime: ${WHITE}${total_time}${YELLOW} seconds \nTotal errors: ${WHITE}${total_errors}${YELLOW}"
    else
        printYellowRed "Total tests run: ${WHITE}${tests_run}${YELLOW} \nTotal tests runtime: ${WHITE}${total_time}${YELLOW} seconds" "\nTotal errors: ${total_errors}"
    fi
    IFS=
}

function runStep() {
    
    local message=${1}
    shift
    
    local COMMAND=$@
    
    #Parse step command
    COMMAND="run_error=0; verify_error=0;"${COMMAND}
    COMMAND=$(\
        echo ${COMMAND} |\
        sed -E -e 's/([A-Z_]*:)/\n\1/g' -e 's/^\n//g' |\
        sed -E -e 's/(RUNTEST:)([^\n]*)/\1\2; run_error=\$?;/g' |\
        sed -E -e 's/(RUN:)([^\n]*)/\1\2;/g' |\
        sed -E -e 's/(VERIFY:)([^\n]*)/\1\2; verify_error=\$((\$run_error | \$verify_error | \$?));/g' |\
        sed -E -e 's/(VERIFY_NOT:)([^\n]*)/\1\2; verify_error=\$((\$run_error | \$verify_error | ! \$?));/g' |\
        sed -E -e 's/(VERIFY_NON_ZERO_EXIT_CODE:)([^\n]*)/; verify_error=\$((! \$run_error | $verify_error)); run_error=0; /g' |\
    tr '\n' ' ' )
    
    COMMAND=${COMMAND}'; [[ $verify_error = "0" ]]'
    COMMAND=${COMMAND//RUNTEST:[[:space:]]/" NO_RED_OUTPUT=false ./"}
    COMMAND=${COMMAND//RUNTESTNOERRPRINT:[[:space:]]/" NO_RED_OUTPUT=true ./"}
    COMMAND=${COMMAND//VERIFY_NOT:[[:space:]]/" NO_RED_OUTPUT=true ${TEST_ROOT_DIR}/${VERIFY_SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//VERIFY:[[:space:]]/" ${TEST_ROOT_DIR}/${VERIFY_SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//RUN:[[:space:]]/;}
#    COMMAND=${COMMAND//;[[:space:]]/;}
    
    COMMAND=$(echo $COMMAND | sed -E -e 's/;([[:space:]]*)/;/g' -e 's/[;]+/;/g')
    
    printWhite "\nStep $((++step))_${SCRIPT_FOLDER}: ${message}"
    printDbg $COMMAND
    
    printLogStepHeader ${step} ${SCRIPT_FOLDER} ${message}
    
    printLog "$@"
    
    #SET INDENTATION FOR /dev/stdout (1 tabulation symbol)
    exec 3>&1
    exec 1> >(paste /dev/null -)
    
    
    local start_time=$(date +"%s.%3N")
    
    # Run command
    eval "${COMMAND}" 2>&1
    local exit_code=$?
    local stop_time=$(date +"%s.%3N")
    
    local time_elapsed=$(awk "BEGIN{print ${stop_time} - ${start_time}}")
    printDbg "Step ${step}_${SCRIPT_FOLDER}: exit code $exit_code"
    
    #RESET INDENTATION FOR /dev/stdout
    exec 1>&3 3>&-
    
    printExitCode "${exit_code}"
    RESULTS+=("${step}_${SCRIPT_FOLDER}|${message}|${exit_code}|${time_elapsed}")
}

main $@
