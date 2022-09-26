#!/usr/bin/env bash

IFS='[]'

main() {
    declare -a RESULTS
    rowSeparator='-|-|-|-'
    VERIFY_SCRIPT_FOLDER='verify'

    runTestScenario $*
}



function runTestScenario() {
    local interfaceTypes
    local scenarioArgs

    checkArgsPassed $@

    interfaceTypes=${4}
    shift 4

    scenarioArgs=$@

    unset IFS

    initResultsTable

    IFS=',' read -r -a INTERFACE_TYPES <<< "${interfaceTypes}"

    for SCRIPT_FOLDER in "${INTERFACE_TYPES[@]}"; do

        printYellowBox "Running ${SCRIPT_FOLDER} tests"
        addTableRowSeparator
        pushd ${TEST_ROOT_DIR}/${SCRIPT_FOLDER}/ >/dev/null
        SCENARIO ${scenarioArgs}
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
        local testStep="$(echo ${result} | cut -d '|' -f 1)"
        local testName="$(echo ${result} | cut -d '|' -f 2)"
        local exitCode="$(echo ${result} | cut -d '|' -f 3)"
        local elapsedTime="$(echo ${result} | cut -d '|' -f 4)"

        if [ "${exitCode}" = "0" ]; then
            tests_run=$(($tests_run + 1))
            total_time=$(LC_NUMERIC='en_US.UTF-8' awk "BEGIN{print ${total_time} + ${elapsedTime}}")
            exitCode="${BRIGHT}${GREEN}OK:  (${exitCode})${NORMAL}"

            elif [[ ! ${exitCode} =~ ^[0-9]+$ ]]; then
            :
        else
            exitCode="${BRIGHT}${RED}ERR: (${exitCode})${NORMAL}"
            total_errors=$(($total_errors + 1))
            tests_run=$(($tests_run + 1))
            total_time=$(LC_NUMERIC='en_US.UTF-8' awk "BEGIN{print ${total_time} + ${elapsedTime}}")
        fi
        IFS='~'
        timing=$(printPaddingSpaces "${exitCode}" "${elapsedTime}" ${l3})

        printf '%-'${l1}'s %-'${l2}'s %-'${l3}'s %-'${l4}'s\n' "${testStep}" "${testName}" "${exitCode}" "${timing}"
    done
    echo ${separator//|/ }

    printColoredText "${BRIGHT}${YELLOW}" "Start time: ${WHITE}${START_TIME}${YELLOW}, End time: ${WHITE}${END_TIME}${YELLOW}"

    if [ "${total_errors}" = 0 ]; then
        echo -e "${BRIGHT}${YELLOW}Total tests run: ${WHITE}${tests_run} ${YELLOW} \nTotal tests duration: ${WHITE}${total_time}${YELLOW} seconds \nTotal errors: ${WHITE}${total_errors}${NORMAL}"
    else
        echo -e "${BRIGHT}${YELLOW}Total tests run: ${WHITE}${tests_run}${YELLOW} \nTotal tests duration: ${WHITE}${total_time}${YELLOW} seconds \n${BRIGHT}${RED}Total errors: ${total_errors}${NORMAL}"
    fi

    printColoredText "${BRIGHT}${YELLOW}" "See debug log ${WHITE}${BRIHT}${FSTEST_LOG_FILE}${NORMAL}"
    echo
    IFS=
}

function runStep() {

    local message=${1}
    shift

    local COMMAND=$@
    local testRedErrOutput

    #Parse step command
    testRedErrOutput="false"
    case "${COMMAND}" in
    *VERIFY_NON_ZERO_EXIT_CODE:*)
        testRedErrOutput="true"
        ;;
    esac

    COMMAND="run_error=0; verify_error=0;"${COMMAND}
    COMMAND=$(\
        echo ${COMMAND} |\
        sed -E -e 's/([A-Z_]*:)/\n\1/g' -e 's/^\n//g' |\
        sed -E -e 's/(RUNTEST:)([^\n]*)/\1\2; run_error=\$?;/g' |\
        sed -E -e 's/(RUN:)([^\n]*)/\1\2;/g' |\
        sed -E -e 's/(VERIFY:)([^\n]*)/\1\2; verify_error=\$((\$run_error | \$verify_error | \$?));/g' |\
        sed -E -e 's/(VERIFY_NOT:)([^\n]*)/\1\2; verify_error=\$((\$run_error | \$verify_error | ! \$?)); echo \"\$(setColorOnError \${verify_error})\${BRIGHT}Non-zero exit code expected \${NORMAL}\"; /g' |\
        sed -E -e 's/(VERIFY_NON_ZERO_EXIT_CODE:)([^\n]*)/; verify_error=\$((! \$run_error | $verify_error)); run_error=0; echo \"\$(setColorOnError \${verify_error})\${BRIGHT}Non-zero exit code expected \${NORMAL}\"; /g' |\
        tr '\n' ' ' )

    COMMAND=${COMMAND}'; [[ $verify_error = "0" ]]'
    COMMAND=${COMMAND//RUNTEST:[[:space:]]/" NO_RED_OUTPUT=${testRedErrOutput} ./"}
    COMMAND=${COMMAND//RUNTESTNOERRPRINT:[[:space:]]/" NO_RED_OUTPUT=true ./"}
    COMMAND=${COMMAND//VERIFY_NOT:[[:space:]]/" NO_RED_OUTPUT=true ${TEST_ROOT_DIR}/${VERIFY_SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//VERIFY:[[:space:]]/" ${TEST_ROOT_DIR}/${VERIFY_SCRIPT_FOLDER}/"}
    COMMAND=${COMMAND//RUN:[[:space:]]/;}

    COMMAND=$(echo $COMMAND | sed -E -e 's/;([[:space:]]*)/;/g' -e 's/[;]+/;/g')

    step=$((${step} + 1))
    printColoredText "${BRIGHT}${WHITE}" "\n\nStep $((step))_${SCRIPT_FOLDER}: ${message}" | printToLogAndToScreen

    printDbg $COMMAND

    #SET INDENTATION FOR /dev/stdout (1 tabulation symbol)
    exec 3>&1
    exec 1> >(paste /dev/null -)

    local startTime=$(LC_TIME="en_US.UTF-8" date +"%s.%3N")
    # Run command
    eval "${COMMAND}" 2>&1
    local exitCode=$?
    local stopTime=$(LC_TIME="en_US.UTF-8" date +"%s.%3N")

    local timeElapsed=$(LC_NUMERIC='en_US.UTF-8' awk "BEGIN{print ${stopTime} - ${startTime}}")

    #RESET INDENTATION FOR /dev/stdout
    exec 1>&3 3>&-

    printExitCode "${exitCode}" "Step ${step}_${SCRIPT_FOLDER} exit code:"
    RESULTS+=("${step}_${SCRIPT_FOLDER}|${message}|${exitCode}|${timeElapsed}")
}

main $@