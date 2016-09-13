#!/bin/sh
openssl req -config cert-template -new -x509 -days 3650 -nodes \
        -out /etc/ssl/certs/ssl-cert-hastur.pem \
        -keyout /etc/ssl/private/ssl-cert-hastur.key
