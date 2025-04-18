#!/bin/bash

# Exit immediately if a command exits with a non-zero status, and print commands as they're executed.
set -x

# Check if .env exists
if [ ! -f .env ]; then
    echo ".env file not found!" >&2
    exit 1
fi

# Clear or create .env_encoded
: > .env_encoded

# Read each non-empty line from .env and process it, even if the last line doesn't have a newline.
while IFS='=' read -r key value || [ -n "$key" ]; do
    # Debug: print the key and value read
    # echo "DEBUG: key='$key' value='$value'" >&2

    # Skip if key or value is empty (also skips empty lines)
    if [[ -z "$key" || -z "$value" ]]; then
        continue
    fi

    # Base64 encode the value (without adding a newline)
    encoded=$(echo -n "$value" | base64)
    echo "SECRET_${key}=${encoded}" >> .env_encoded
done < .env

# Encodes the service account file without line wrapping to make sure the whole JSON value is intact.
echo "SECRET_GCP_SERVICE_ACCOUNT=$(cat ../.secrets/my-creds.json | base64 -w 0)" >> .env_encoded