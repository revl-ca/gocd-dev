#!/usr/bin/env bash

set -e

REPOSITORIES_FILE=${PROFILES_FILE:="./scripts/repositories.txt"}

source $(dirname $0)/common.sh

repository_payload() {
  local NAME="$1"
  local URL="$2"
  local BRANCH="$3"

  cat <<EOF
{
  "id": "$NAME-repository",
  "plugin_id": "yaml.config.plugin",
  "material_update_in_progress": false,
  "configuration": [],
  "material": {
    "type":"git",
    "attributes": {
      "url": "$URL",
      "password": "",
      "branch": "$BRANCH"
    }
  }
}
EOF
}

create_repositories() {
  local FILE="$1"

  if [ -f "$FILE" ]; then
    while IFS= read -r REPOSITORY; do
      if [ -z "$REPOSITORY" ]; then
        return
      fi

      local REPOSITORY_NAME=$(echo "$REPOSITORY" | awk '{ print $1 }')
      local REPOSITORY_URL=$(echo "$REPOSITORY" | awk '{ print $2 }')
      local REPOSITORY_BRANCH=$(echo "$REPOSITORY" | awk '{ print $3 }')

      echo "Creating repository $REPOSITORY_NAME."

      curl --silent -i "$GO_SERVER_URL_HTTP/api/admin/config_repos" \
        -H 'Accept: application/vnd.go.cd.v2+json' \
        -H 'Content-Type: application/json' \
        -X POST -d "$(repository_payload "$REPOSITORY_NAME" "$REPOSITORY_URL" "$REPOSITORY_BRANCH")"
    done < "$FILE"
  else
    echo "File $FILE not found." 2>&1
  fi
}

echo "Creating repositories..."

create_repositories "$REPOSITORIES_FILE"

