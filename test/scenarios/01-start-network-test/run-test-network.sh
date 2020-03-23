#!/usr/bin/env bash

TARGET=${DEPLOYMENT_TARGET:?"\${DEPLOYMENT_TARGET} (local,vbox) is not set."}
echo "Deploing network for <${TARGET}> target. Domain: $DOMAIN, Orgs: ${ORG1} ${ORG2}"
echo "\${DOCKER_REGISTRY} is set to: <${DOCKER_REGISTRY}>"
echo "\${MULTIHOST} is set to: <${MULTIHOST}>"
sleep 2

case "${TARGET}" in

    local)
unset MULTIHOST
pushd ../../../ >/dev/null
./network-create-local.sh ${ORG1} ${ORG2}
popd >/dev/null
    ;;
    vbox)

pushd ../../../ >/dev/null
./network-docker-machine-create.sh  ${ORG1} ${ORG2}
VBOX_HOST_IP=${VBOX_HOST_IP:-$(VBoxManage list hostonlyifs | grep 'IPAddress' | cut -d':' -f2 | sed -e 's/^[[:space:]]*//')}
REGISTRY="${VBOX_HOST_IP}:5000"
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-${REGISTRY}}
popd >/dev/null
    ;;
    *) 
    echo "Wrong target <${TARGET}>"
    ;;
esac
