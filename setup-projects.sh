#!/bin/bash
set -e

if [[ ! -f .env ]]; then
  cp .env.example .env
fi


source .env

[[ -d "$MAX_PATH" ]] || git clone $MAX_URL $MAX_PATH
bash -c "cd $MAX_PATH; make setup || echo error while make setup in $MAX_PATH"

[[ -d "$LOGIN_CONTROLLER_PATH" ]] || git clone $LOGIN_CONTROLLER_URL $LOGIN_CONTROLLER_PATH
bash -c "cd $LOGIN_CONTROLLER_PATH; make setup || echo error while make setup in $LOGIN_CONTROLLER_PATH"

[[ -d "$REGISTER_API_PATH" ]] || git clone $REGISTER_API_URL $REGISTER_API_PATH
bash -c "cd $REGISTER_API_PATH; make setup || echo error while make setup in $REGISTER_API_PATH"

[[ -d "$YIVI_DISCLOSURE_PATH" ]] || git clone $YIVI_DISCLOSURE_URL $YIVI_DISCLOSURE_PATH
bash -c "cd $YIVI_DISCLOSURE_PATH; make setup || echo error while make setup in $YIVI_DISCLOSURE_PATH"

[[ -d "$OIDC_PROVIDER_PATH" ]] || git clone $OIDC_PROVIDER_URL $OIDC_PROVIDER_PATH
bash -c "cd $OIDC_PROVIDER_PATH; make setup || echo error while make setup in $OIDC_PROVIDER_PATH"

[[ -d "$PROEFTUIN_PATH" ]] || git clone $PROEFTUIN_URL $PROEFTUIN_PATH
bash -c "cd $PROEFTUIN_PATH; make setup || echo error while make setup in $PROEFTUIN_PATH"
