#!/bin/bash

apk add aws-cli jq

nc -zvw30 $VAULT_ENDPOINT $VAULT_PORT

export VAULT_ADDR="http://$VAULT_ENDPOINT:$VAULT_PORT"

INIT_RESPONSE=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)

if [[ -z "$INIT_RESPONSE" ]]; then
    exit 0
fi

UNSEAL_KEY=$(echo "$INIT_RESPONSE" | jq -r .unseal_keys_b64[0])
ROOT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r .root_token)

aws ssm put-parameter --name "/vault/root" --value "$ROOT_TOKEN" --type SecureString
aws ssm put-parameter --name "/vault/unseal_key" --value "$UNSEAL_KEY" --type SecureString
