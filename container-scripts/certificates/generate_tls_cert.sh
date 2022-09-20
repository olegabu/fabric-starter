#!/usr/bin/env bash

function main() {
    local outputRootDir=${1:-/certs/}
    local templatesDir=${2:-/etc/hyperledger/templates}
    generateCertificates "$outputRootDir" "$templatesDir"
}

function generateCertificates() {
    local outputRootDir=${1:?Output dir is required}
    local templatesDir=${2:?Templates dir is required}

    if [ ! -f "${outputRootDir}/public.crt" ]; then
        openssl req -new -newkey rsa:4096 -x509 -sha256 -days ${CERT_DAYS:-365} -nodes -out /certs/public.crt -keyout /certs/private.key -config "${templatesDir}/openssl-cert.conf";
    else
        echo "Using existing certs in `ls ${outputRootDir}`"
    fi
    echo "public.crt:"
    cat "${outputRootDir}/public.crt"

    mkdir -p "${outputRootDir}/${ORG:-org1}.${DOMAIN:-example.com}"
    cp "${outputRootDir}/public.crt" "${outputRootDir}/${ORG:-org1}.${DOMAIN:-example.com}"
    cp "${outputRootDir}/private.key" "${outputRootDir}/${ORG:-org1}.${DOMAIN:-example.com}"
}

main $@
