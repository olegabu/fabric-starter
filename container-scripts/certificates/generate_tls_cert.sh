#!/usr/bin/env bash
env|sort
echo ---

function main() {
    copyTemplatesToBeAvailableByNginxContainers
    generateCertificates
}

function generateCertificates() {
    if [ ! -f '/certs/public.crt' ]; then
        openssl req -new -newkey rsa:4096 -x509 -sha256 -days ${CERT_DAYS} -nodes -out /certs/public.crt -keyout /certs/private.key -config /crypto-config/templates/openssl-cert.conf;
    else
        echo "using exisiting /certs/public.crt"
    fi
    echo "public.crt:"
    cat /certs/public.crt
    echo "private.key:"
    cat /certs/private.key
}

function copyTemplatesToBeAvailableByNginxContainers() {
    echo "copy Templates To Be Available By Nginx Container"
    set -x
    cp -r /etc/hyperledger/templates /crypto-config/
    ls /crypto-config/templates
    set +x
}

main
