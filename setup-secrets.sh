#!/bin/bash

set -e

SECRETS_DIR=secrets

create_key_pair () {
  echo "generating keypair and certificate $1/$2 with CN:$3"
  openssl genrsa -out $1/$2.key 2048
  openssl rsa -in $1/$2.key -pubout > $1/$2.pub
  openssl req -new -sha256 \
    -key $1/$2.key \
    -subj "/C=US/CN=$3" \
    -out $1/$2.csr
  openssl x509 -req -days 500 -sha256 \
    -in $1/$2.csr \
    -CA $SECRETS_DIR/cacert.crt \
    -CAkey $SECRETS_DIR/cacert.key \
    -CAcreateserial \
    -out $1/$2.crt
  rm $1/$2.csr
}

mkdir -p ./$SECRETS_DIR

###
 # Create ca for local selfsigned certificates
###
if [[ ! -f $SECRETS_DIR/cacert.crt ]]; then
  openssl genrsa -out $SECRETS_DIR/cacert.key 4096
	openssl req -x509 -new -nodes -sha256 -days 1024 \
	  -key $SECRETS_DIR/cacert.key \
	  -out $SECRETS_DIR/cacert.crt \
	  -subj "/CN=US/CN=inge-6-uzipoc-ca"
fi

###
# nl-rdo-max certs
###
if [[ ! -f $SECRETS_DIR/nl-rdo-max.crt ]]; then
  create_key_pair $SECRETS_DIR "nl-rdo-max" "nl-rdo-max"
fi

###
# nl-uzi-login-controller certs
###
if [[ ! -f $SECRETS_DIR/nl-uzi-login-controller.crt ]]; then
  create_key_pair $SECRETS_DIR "nl-uzi-login-controller" "nl-uzi-login-controller"
fi

###
# nl-uzipoc-register-api certs
###
if [[ ! -f $SECRETS_DIR/nl-uzipoc-register-api.crt ]]; then
  create_key_pair $SECRETS_DIR "nl-uzipoc-register-api" "nl-uzipoc-register-api"
fi

###
# nl-uzi-yivi-disclosure-web certs
###
if [[ ! -f $SECRETS_DIR/nl-uzi-yivi-disclosure-web.crt ]]; then
  create_key_pair $SECRETS_DIR "nl-uzi-yivi-disclosure-web" "nl-uzi-yivi-disclosure-web"
fi

# nl-uzipoc-php-laravel-demo
###
if [[ ! -f $SECRETS_DIR/nl-uzipoc-php-laravel-demo.crt ]]; then
  create_key_pair $SECRETS_DIR "nl-uzipoc-php-laravel-demo" "nl-uzipoc-php-laravel-demo"
fi

###
# nl-rdo-uzipoc-oidc-provider
###
if [[ ! -f $SECRETS_DIR/nl-rdo-uzipoc-oidc-provider.crt ]]; then
  create_key_pair $SECRETS_DIR "nl-rdo-uzipoc-oidc-provider" "nl-rdo-uzipoc-oidc-provider"
fi