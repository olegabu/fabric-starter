#!/usr/bin/env bash
[ "${0#*-}" = "bash" ] && BASEDIR=$(dirname ${BASH_SOURCE[0]}) || BASEDIR=$(dirname $0) #extract script's dir
export TEST_LAUNCH_DIR=$(pwd)

pushd ${BASEDIR}/../../ >/dev/null
BASEDIR=.
source libs/libs.sh 

#echo "run_scenario.sh $$ : Starting in $BRIGHT $RED $(pwd), $WHITE Basedir is $BASEDIR $NORMAL"

ARGS_PASSED=("$@")

ARGS_REQUIRED=(
    "Fabric_test_interface":interface_types
    "First_organization":org1
    "Second_organization":org2
)

#COMMON_CHANNEL='common'



SCENARIO() {

orgs_csv_local=\
"api.${org1}.${DOMAIN}",\
"api.${org2}.${DOMAIN}",\
"ca.${org1}.${DOMAIN}",\
"ca.${org2}.${DOMAIN}",\
"cli.orderer.${DOMAIN}",\
"cli.${org1}.${DOMAIN}",\
"cli.${org2}.${DOMAIN}",\
"couchdb.peer0.${org1}.${DOMAIN}",\
"couchdb.peer0.${org2}.${DOMAIN}",\
"orderer.${DOMAIN}",\
"peer0.${org1}.${DOMAIN}",\
"peer0.${org2}.${DOMAIN}",\
"www.${org1}.${DOMAIN}",\
"www.${DOMAIN}",\
"www.${org2}.${DOMAIN}"

orgs_csv_vbox_org1=\
"api.${org1}.${DOMAIN}",\
"ca.${org1}.${DOMAIN}",\
"cli.orderer.${DOMAIN}",\
"cli.${org1}.${DOMAIN}",\
"couchdb.peer0.${org1}.${DOMAIN}",\
"orderer.${DOMAIN}",\
"peer0.${org1}.${DOMAIN}",\
"www.${org1}.${DOMAIN}",\
"www.${DOMAIN}"

orgs_csv_vbox_org2=\
"api.${org2}.${DOMAIN}",\
"ca.${org2}.${DOMAIN}",\
"cli.${org2}.${DOMAIN}",\
"couchdb.peer0.${org2}.${DOMAIN}",\
"peer0.${org2}.${DOMAIN}",\
"www.${org2}.${DOMAIN}"


case "${DEPLOYMENT_TARGET}" in #get rid of this

    local)
    runStep "Test 'Docker containers for local network are up and running'" "${SCRIPT_FOLDER}" \
        VERIFY:   ./test-containers-list.sh ${DOMAIN} ${org1} ${orgs_csv_local}
    ;;
    vbox)
    runStep "Test 'Docker containers for vbox <${org1}> machine are up and running'" "${SCRIPT_FOLDER}" \
        VERIFY:   ./test-containers-list.sh ${DOMAIN} ${org1} ${orgs_csv_vbox_org1}

    runStep "Test 'Docker containers for vbox <${org2}> machine are up and running'" "${SCRIPT_FOLDER}" \
        VERIFY:   ./test-containers-list.sh ${DOMAIN} ${org2} ${orgs_csv_vbox_org2}
    ;;
    *) 
    echo "Wrong target <${DEPLOYMENT_TARGET}>"
    ;;
esac

    runStep "Test 'Organization ${org1} is in <common> channel'" "${SCRIPT_FOLDER}" \
        VERIFY:     test-channel-exists.sh 'common' ${org1} 

    runStep "Test 'Organization ${org2} is in <common> channel'" "${SCRIPT_FOLDER}" \
        VERIFY:     test-channel-exists.sh 'common' ${org2} 

    runStep "Test 'Organization ${org1} joined the <common> channel'" "${SCRIPT_FOLDER}" \
        VERIFY:  test-join-channel.sh 'common' ${org1}

    runStep "Test 'Organization ${org2} joined the <common> channel'" "${SCRIPT_FOLDER}" \
        VERIFY:  test-join-channel.sh 'common' ${org2}
}

export -f SCENARIO
source libs/lib-scenario.sh $@

popd >/dev/null