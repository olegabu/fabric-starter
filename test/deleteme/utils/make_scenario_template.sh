#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
SCENARIO_DIR=''
SCENARIO_FILE="${BASEDIR}/${SCENARIO_DIR}/${1}"

scenario_name=${1:?Please provide the name of scenario}

echo ${SCENARIO_FILE}

cat > ${SCENARIO_FILE} <<'EOF'
#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)

pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 

ARGS_PASSED=("$@")

ARGS_REQUIRED=(
    "Fabric_test_interface":interface_types
    "First_organization":org1
    "Second_organization":org2
)

#RUNTEST: run script from cli|api foledr
#VERIFY: run verify script from verify folder
#SKIPCLI: skip step if testing via CLI commands
#SKIPAPI: skip step if testing via REST API
#RUNTESTNOERRPRINT: run test, do not print errors in red
#RUN: run any command



SCENARIO() {
    
    SCRIPT_FOLDER=$1 #cli|curl
    TEST_CHANNEL_NAME=$2
    TEST_CHAINCODE_NAME=$3

# Creating channels    

    TEST_CHANNEL_WRONG_NAME="^^^^^^"${TEST_CHANNEL_NAME}
    TEST_SECOND_CHANNEL_NAME=${TEST_CHANNEL_NAME}"-02"

    runStep "Test 'Create Channel in ORG1'" "${SCRIPT_FOLDER}" \
        RUNTEST:    create-channel.sh       ${TEST_CHANNEL_NAME} ${org1} \
        VERIFY:     test-channel-exists.sh  ${TEST_CHANNEL_NAME} ${org1}

}


export -f SCENARIO
source libs/lib-scenario.sh $@

popd

EOF

chmod +x ${SCENARIO_FILE}