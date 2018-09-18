#!/usr/bin/env bash

source lib.sh

NEWORG=$1
consortiumName=${2:-"SampleConsortium"}

[ -z "$NEWORG" ] && echo "Organization to be added to consortium must be specified" && exit 1
[ -z "$consortiumName" ] && echo "Consortium Name must be specified" && exit 1

echo "Add $NEWORG to consortium $consortiumName"

EXECUTE_BY_ORDERER=1 downloadMSP ${NEWORG}
EXECUTE_BY_ORDERER=1 txTranslateChannelConfigBlock "orderer-system-channel"
EXECUTE_BY_ORDERER=1 updateConsortium $NEWORG "orderer-system-channel"
