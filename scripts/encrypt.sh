#!/usr/bin/env bash

set -e

VALUE="${1?A value to be encrypted must be specified}"

source $(dirname $0)/common.sh

encrypt_payload() {
  cat <<EOF
{
  "value": "$VALUE"
}
EOF
}

echo "Creating secret."

ENCRYPTED_VALUE=$(curl --silent "$GO_SERVER_URL_HTTP/api/admin/encrypt" \
  --fail \
  -H 'Accept: application/vnd.go.cd.v1+json'  \
  -H 'Content-Type: application/json' \
  -X POST -d "$(encrypt_payload)" | parse_property 'encrypted_value')

echo "encrypted_value $ENCRYPTED_VALUE"

