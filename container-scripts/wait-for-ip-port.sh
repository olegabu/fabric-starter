#!/usr/bin/env bash
host=${1}
port=${2}
waitTime=${3:-120}

function portProbe() {
    local testHost=${1}
    local testPort=${2}
    local exitCode
    echo "Waiting for ${testHost}:${testPort}"
    
    while true
    do nc -z ${testHost} ${testPort}
        exitCode=$?
        if [[ ${exitCode} -eq 0 ]]; then
            break
        fi
        sleep 0.5
    done
    return ${exitCode}
}
export -f portProbe

timeout ${waitTime} bash -c "portProbe ${host} ${port}"
echo "Result code: $?"