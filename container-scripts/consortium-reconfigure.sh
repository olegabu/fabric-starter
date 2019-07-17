#!/usr/bin/env bash
source lib/container-lib.sh 2>/dev/null # for IDE code completion
source $(dirname "$0")/container-lib.sh

if [ -n "${CONSORTIUM_CONFIG}" ]; then
    echo -e "\n\nApplying consortium reconfiguration: ${CONSORTIUM_CONFIG}\n\n"
    updateConsortium orderer ${SYSTEM_CHANNEL_ID} "./templates/Consortium-${CONSORTIUM_CONFIG}.json"
fi
