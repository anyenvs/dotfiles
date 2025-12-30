#!/bin/sh

# forward stderr to stdout for use with runit svlogd
exec 2>&1

PRIVOXY_CERTS_PATH="/etc/privoxy/certs"
#PRIVOXY_USER="privoxy"
PRIVOXY_USER="501"

test -d $PRIVOXY_CERTS_PATH || mkdir -pv $PRIVOXY_CERTS_PATH

## PRIVOXY_CERTS generation
openssl req -new -x509 -extensions v3_ca -keyout $PRIVOXY_CERTS_PATH/privoxy.pem -out $PRIVOXY_CERTS_PATH/privoxy.crt -days 3650

## PRIVOXY_CERTS ownership for privoxy
chmod 600 $PRIVOXY_CERTS_PATH/privoxy.pem
chown $PRIVOXY_USER $PRIVOXY_CERTS_PATH/privoxy.pem

## PRIVOXY_CERTS_PATH ownership for privoxy
chown $PRIVOXY_CERTS_PATH /var/lib/privoxy/certs
chmod 700 /var/lib/privoxy/certs

echo <<EOT
## https://www.privoxy.org/user-manual/howto.html#H2-HI-CONFIG
ca-directory /etc/privoxy/CA # read-only
ca-cert-file $PRIVOXY_CERTS_PATH/privoxy.crt     # in ca-directory
ca-key-file $PRIVOXY_CERTS_PATH/privoxy.pem      # in ca-directory
ca-password passphrasefromabove
certificate-directory /var/lib/privoxy/certs
trusted-cas-file /etc/ssl/certs/ca-certificates.crt
EOT > config-ssl
