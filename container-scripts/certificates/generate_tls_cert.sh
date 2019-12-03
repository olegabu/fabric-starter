#!/usr/bin/env bash
if [ ! -f '/certs/public.crt' ]; then
    openssl req -new -newkey rsa:4096 -x509 -sha256 -days ${CERT_DAYS} -nodes -out /certs/public.crt -keyout /certs/private.key -config /templates/openssl-cert.conf;
fi