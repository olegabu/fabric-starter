#!/usr/bin/env bash
#[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir

#echo "lib_scenario.sh: Starting in $BRIGHT $BLUE $(pwd), $WHITE Basedir is $BASEDIR $NORMAL"

IFS='[]' 

main() {
    export -a RESULTS
    export step
    export rowSeparator='-|-|-|-'
    export VERIFY_SCRIPT_FOLDER='verify'
    runTestScenario $*

}


function runTestScenario() {
#    echo "runTestScenario all params: $*"
#    echo "first param\@: $@"
    scenarioArgsParse $@ #required args is the first parameter passed
unset IFS

    initResultsTable

echo "IFS=              $IFS"

    INTERFACE_TYPES=($(sed -e 's/,/ /g' <<<${interface_types}))
    for SCRIPT_FOLDER in "${INTERFACE_TYPES[@]}"; do

        TEST_CHANNEL_NAME=$(getRandomChannelName)
        TEST_CHAINCODE_NAME=$(getTestChaincodeName ${TEST_CHANNEL_NAME})
        printYellowBox "Running ${SCRIPT_FOLDER} tests"
        addTableRowSeparator
        SCENARIO ${SCRIPT_FOLDER} ${TEST_CHANNEL_NAME} ${TEST_CHAINCODE_NAME}
    done
    printTestResultTable
}


function initResultsTable() {

    RESULTS+=("STEP|TEST NAME|RESULT|TIME ELAPSED (s)")
}

function addTableRowSeparator() {
    RESULTS+=("${rowSeparator}")
}

function printTestResultTable() {
    local textlength=10
    local length

    echo -e "\n\n"

    for line_n in "${RESULTS[@]}"; do
        local line="$(echo ${line_n} | cut -d '|' -f 2)"
        local length=$(expr length "${line}")
        if [ "${length}" -gt "${textlength}" ]; then
            textlength=${length}
        fi
    done

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

    if [ "${total_errors}" = 0 ]; then
        printYellow "Total tests run: ${WHITE}${tests_run}${YELLOW} \nTotal tests runtime: ${WHITE}${total_time}${YELLOW} seconds \nTotal errors: ${WHITE}${total_errors}${YELLOW}"
    else
        printYellowRed "Total tests run: ${WHITE}${tests_run}${YELLOW} \nTotal tests runtime: ${WHITE}${total_time}${YELLOW} seconds" "\nTotal errors: ${total_errors}"
    fi
    IFS=
    sleep 10
}

function runStep() {
    local message=${1}
    local script_folder=${2}
    shift 2
    COMMAND=$@

    if [[ "$COMMAND" =~ "SKIP:" ]]; then
        local exit_code=0
        printWhite "\nStep x_${script_folder}: ${message} -- SKIPPING (due to SKIP: command)"
        printExitCode "${exit_code}"
        RESULTS+=("x_${script_folder}|${message}|skipped|0")
        return $exit_code
    fi

    if [[ "$COMMAND" =~ "SKIPCLI:" ]]; then
        if [[ "${script_folder}" =~ "cli" ]]; then
            local exit_code=0
            printWhite "\nStep x_${script_folder}: ${message} -- SKIPPING (due to SKIPCLI: command)"
            printExitCode "${exit_code}"
            RESULTS+=("x_${script_folder}|${message}|skipped|0")
            return $exit_code

        else
            COMMAND=${COMMAND//SKIPCLI:[[:space:]]/}
        fi
    fi

    if [[ "$COMMAND" =~ "SKIPAPI:" ]]; then
        if [[ "${script_folder}" =~ "api" ]]; then
            local exit_code=0
            printWhite "\nStep x_${script_folder}: ${message} -- SKIPPING (due to SKIPAPI: command)"
            printExitCode "${exit_code}"
            RESULTS+=("x_${script_folder}|${message}|skipped|0")
            return $exit_code
        else
            COMMAND=${COMMAND//SKIPAPI:[[:space:]]/}
        fi
    fi

    COMMAND=${COMMAND//RUNTEST:[[:space:]]/" ; NO_RED_OUTPUT=false ${TEST_ROOT_DIR}/${SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//RUNTESTNOERRPRINT:[[:space:]]/" ; NO_RED_OUTPUT=true ${TEST_ROOT_DIR}/${SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//VERIFY:[[:space:]]/" ; ${TEST_ROOT_DIR}/${VERIFY_SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//RUN:[[:space:]]/;}
    COMMAND=$(echo ${COMMAND} | sed -e s'/^;//')

    printWhite "\nStep $((++step))_${script_folder}: ${message}"
    printDbg $COMMAND
    printLog "${BRIGHT}${WHITE}---------------------------${NORMAL}"
    printLog "${BRIGHT}${WHITE}Step: ${step}_${script_folder} ${message}${NORMAL}"
    printLog "${BRIGHT}${WHITE}---------------------------${NORMAL}"

    printLog "$@"

    COMMAND=${COMMAND}

    #SET INDENTATION FOR /dev/stdout (1 tabulation symbol)
    exec 3>&1
    exec 1> >(paste /dev/null -)
    local start_time=$(date +"%s.%3N")
    eval "${COMMAND}" 2>&1
    local exit_code=$?
    local stop_time=$(date +"%s.%3N")

    local time_elapsed=$(awk "BEGIN{print ${stop_time} - ${start_time}}")
    printDbg "Step ${step}_${script_folder}: exit code $exit_code"

    #RESET INDENTATION FOR /dev/stdout
    exec 1>&3 3>&-

    printExitCode "${exit_code}"
    RESULTS+=("${step}_${script_folder}|${message}|${exit_code}|${time_elapsed}")
}

#IFS=']' 
main $@
