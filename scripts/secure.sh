#!/usr/bin/env bash

set -e

GO_SERVER_IP=$(ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{ print $1 }')
PASSWORD_FILE_LOCATION=${PASSWORD_FILE_LOCATION:="/home/go/password"}

GOCD_USERNAME="${1?You must specify a Username, eg: GOCD_USERNAME='admin'}"
GOCD_PASSWORD="${2?You must specify a Password, eg: GOCD_PASSWORD='admin'}"

source $(dirname $0)/common.sh

generate_password() {
  local USERNAME="$1"
  local PASSWORD="$2"

  echo "$USERNAME:$(python -c "import sha; from base64 import b64encode; print b64encode(sha.new('$PASSWORD').digest())")"
}

secure_payload() {
  local PASSWORD_FILE_LOCATION="$1"

  cat <<EOF
{
  "id": "admin",
  "plugin_id": "cd.go.authentication.passwordfile",
  "properties": [
    {
      "key": "PasswordFilePath",
      "value": "$PASSWORD_FILE_LOCATION"
    }
  ]
}
EOF
}

echo "Creating the password file at $PASSWORD_FILE_LOCATION."

echo $(generate_password "$GOCD_USERNAME" "$GOCD_PASSWORD") > $PASSWORD_FILE_LOCATION

echo "Securing the server."

curl --silent -i "$GO_SERVER_URL_HTTP/api/admin/security/auth_configs" \
  -H 'Accept: application/vnd.go.cd.v2+json' \
  -H 'Content-Type: application/json' \
  -X POST -d "$(secure_payload "$PASSWORD_FILE_LOCATION")"

