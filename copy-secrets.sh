#!/bin/bash

set -e

source .env

SECRETS_DIR=secrets

mkdir -p $MAX_PATH/secrets/clients/laravel-demo
mkdir -p $LOGIN_CONTROLLER_PATH/secrets
mkdir -p $REGISTER_API_PATH/secrets
mkdir -p $YIVI_DISCLOSURE_PATH/secrets
mkdir -p $OIDC_PROVIDER_PATH/secrets
mkdir -p $OIDC_PROVIDER_PATH/secrets/clients

cp $SECRETS_DIR/nl-rdo-max.* $MAX_PATH/secrets/
cp $SECRETS_DIR/nl-uzi-login-controller.* $LOGIN_CONTROLLER_PATH/secrets/
cp $SECRETS_DIR/nl-uzipoc-register-api.* $REGISTER_API_PATH/secrets/
cp $SECRETS_DIR/nl-uzi-yivi-disclosure-web.* $YIVI_DISCLOSURE_PATH/secrets/
cp $SECRETS_DIR/nl-rdo-uzipoc-oidc-provider.* $OIDC_PROVIDER_PATH/secrets/
cp $SECRETS_DIR/nl-uzipoc-php-laravel-demo.* $PROEFTUIN_PATH/secrets/

cp $SECRETS_DIR/nl-rdo-max.crt $LOGIN_CONTROLLER_PATH/secrets/
cp $SECRETS_DIR/nl-rdo-max.crt $REGISTER_API_PATH/secrets/
cp $SECRETS_DIR/nl-rdo-max.crt $MAX_PATH/secrets/jwks-certs/

cp $SECRETS_DIR/nl-uzi-login-controller.crt $REGISTER_API_PATH/secrets/

cp $SECRETS_DIR/nl-uzipoc-register-api.crt $MAX_PATH/secrets/jwks-certs/

cp $SECRETS_DIR/nl-uzi-yivi-disclosure-web.crt $MAX_PATH/secrets/clients/test_client/test_client.crt

cp $SECRETS_DIR/nl-rdo-uzipoc-oidc-provider.pub $LOGIN_CONTROLLER_PATH/secrets/

cp $SECRETS_DIR/nl-uzi-login-controller.pub $OIDC_PROVIDER_PATH/secrets/clients

cp $SECRETS_DIR/nl-uzipoc-register-api.crt $LOGIN_CONTROLLER_PATH/secrets/

cp $SECRETS_DIR/nl-uzipoc-php-laravel-demo.crt $MAX_PATH/secrets/clients/laravel-demo
