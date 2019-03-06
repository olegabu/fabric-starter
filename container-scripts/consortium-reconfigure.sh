#!/usr/bin/env bash
source ./container-lib.sh 2>/dev/null # for code completion
source $(dirname "$0")/container-lib.sh

if [ -n "${CONSORTIUM_CONFIG}" ]; then
    echo "Applying consortium reconfiguration: ${CONSORTIUM_CONFIG}"
    updateConsortium orderer ${SYSTEM_CHANNEL_ID} "./templates/Consortium-${CONSORTIUM_CONFIG}.json"
fi
