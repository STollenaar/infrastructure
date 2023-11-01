#!/bin/bash

apk add curl jq

# nc -zvw10 $1 $2 && exit 1 || echo "continue."

INIT_RESPONSE=$(vault operator init -key-shares=1 -key-threshold=1 -format=json)

if [[ -z "$INIT_RESPONSE" ]]; then
    exit 0
fi

UNSEAL_KEY=$(echo "$INIT_RESPONSE" | jq -r .unseal_keys_b64[0])
ROOT_TOKEN=$(echo "$INIT_RESPONSE" | jq -r .root_token)

HCP_API_TOKEN=$(curl --location 'https://auth.hashicorp.com/oauth/token' \
    --header 'content-type: application/json' \
    --data '{
         "audience": "https://api.hashicorp.cloud",
         "grant_type": "client_credentials",
         "client_id": "'$HCP_CLIENT_ID'",
         "client_secret": "'$HCP_CLIENT_SECRET'"
     }' | jq -r .access_token)

curl -XPOST https://api.cloud.hashicorp.com/secrets/2023-06-13/organizations/$HCP_ORG_ID/projects/$HCP_PROJECT_ID/apps/$HCP_APP_NAME/kv \
    --data '{"name":"root","value":"'"$ROOT_TOKEN"'"}' \
    --header "Authorization: Bearer $HCP_API_TOKEN"

curl -XPOST https://api.cloud.hashicorp.com/secrets/2023-06-13/organizations/$HCP_ORG_ID/projects/$HCP_PROJECT_ID/apps/$HCP_APP_NAME/kv \
    --data '{"name":"unseal_key","value":"'"$UNSEAL_KEY"'"}' \
    --header "Authorization: Bearer $HCP_API_TOKEN"

vault operator unseal $UNSEAL_KEY
