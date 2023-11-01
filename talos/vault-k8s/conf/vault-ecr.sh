#!/bin/bash

yum install -y jq

# Getting the ecr auth token
ecrAuth=$(echo "AWS:$(aws ecr get-login-password --region ca-central-1)" | base64 -w0)

# Parsing into a format for the dockerconfigjson
dockerAuth=$(jq -nc --arg ecrAuth "$ecrAuth" --arg repo "$ECR_REPO" '{"auths":{($repo):{"auth":$ecrAuth}}}')

# get the mounted service account token
token="$(cat /vault/secrets/.token)" #TODO: FIX GET VALID TOKEN

# update the secret using curl
curl \
    --header "X-Vault-Token: $token" \
    --header "Content-Type: application/merge-patch+json" \
    --request PATCH \
    --data '{"data":{".dockerconfigjson":'"$dockerAuth"'}}' \
    "$VAULT_ADDR/v1/secret/data/ecr-auth"
