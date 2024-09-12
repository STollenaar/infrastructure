#!/bin/bash

# Set the profile you want to use for MFA
if [[ "$1" == "" ]]; then
    echo "Missing source profile"
    exit 1
fi

if [[ "$2" == "" ]]; then
    echo "Missing MFA token"
    exit 1
fi

SOURCE_PROFILE="$1"
MFA_PROFILE="mfa"
MFA_TOKEN="$2"

ACCOUNT_ID=$(aws sts get-caller-identity --profile "$SOURCE_PROFILE" | jq -r '.Account')

# Get the temporary credentials
CREDENTIALS=$(aws sts get-session-token \
    --serial-number "arn:aws:iam::$ACCOUNT_ID:mfa/$SOURCE_PROFILE" \
    --token-code "$MFA_TOKEN" \
    --profile "$SOURCE_PROFILE" \
    --output json 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Error: Failed to obtain temporary credentials. Please check your MFA token code and try again."
    exit 1
fi

# Extract the credentials from the JSON response
ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r '.Credentials.AccessKeyId')
SECRET_KEY=$(echo "$CREDENTIALS" | jq -r '.Credentials.SecretAccessKey')
SESSION_TOKEN=$(echo "$CREDENTIALS" | jq -r '.Credentials.SessionToken')
EXPIRATION=$(echo "$CREDENTIALS" | jq -r '.Credentials.Expiration')

# Check if the credentials are not empty
if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ] || [ -z "$SESSION_TOKEN" ]; then
    echo "Error: Failed to parse temporary credentials. Please try again."
    exit 1
fi

# Store the temporary credentials in the mfa profile
aws configure set aws_access_key_id "$ACCESS_KEY"
aws configure set aws_secret_access_key "$SECRET_KEY"
aws configure set aws_session_token "$SESSION_TOKEN"

echo "Temporary credentials have been set for the '$SOURCE_PROFILE' profile. They will expire on $EXPIRATION."
