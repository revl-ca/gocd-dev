#!/usr/bin/env bash

set -e

REPOSITORIES_FILE=${PROFILES_FILE:="./scripts/repositories.txt"}

source $(dirname $0)/common.sh

repository_group_payload() {
  local NAME="$1"

  cat <<EOF
{
  "name": "$NAME"
}
EOF
}

repository_payload() {
  local NAME="$1"
  local URL="$2"
  local BRANCH="$3"
  local GROUP="$4"

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
  },
  "rules": [
    {
      "directive": "allow",
      "action": "refer",
      "type": "pipeline_group",
      "resource": "$GROUP"
    }
  ]
}
EOF
}

create_repository_groups() {
  local FILE="$1"

  if [ -f "$FILE" ]; then
    while IFS= read -r REPOSITORY; do
      if [ -z "$REPOSITORY" ]; then
        return
      fi

      local REPOSITORY_GROUP=$(echo "$REPOSITORY" | awk '{ print $4 }')

      echo "Creating repository group $REPOSITORY_GROUP."
      echo "$GO_SERVER_URL_HTTP/api/admin/pipeline_groups"

      curl --silent -i "$GO_SERVER_URL_HTTP/api/admin/pipeline_groups" \
        -H 'Accept: application/vnd.go.cd+json' \
        -H 'Content-Type: application/json' \
        -X POST -d "$(repository_group_payload "$REPOSITORY_GROUP")"
    done < "$FILE"
  else
    echo "File $FILE not found." 2>&1
  fi
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
      local REPOSITORY_GROUP=$(echo "$REPOSITORY" | awk '{ print $4 }')

      echo "Creating repository $REPOSITORY_NAME."

      curl --silent -i "$GO_SERVER_URL_HTTP/api/admin/config_repos" \
        -H 'Accept: application/vnd.go.cd+json' \
        -H 'Content-Type: application/json' \
        -X POST -d "$(repository_payload "$REPOSITORY_NAME" "$REPOSITORY_URL" "$REPOSITORY_BRANCH" "$REPOSITORY_GROUP")"
    done < "$FILE"
  else
    echo "File $FILE not found." 2>&1
  fi
}

echo "Create repository groups..."

create_repository_groups "$REPOSITORIES_FILE"

echo "Creating repositories..."

create_repositories "$REPOSITORIES_FILE"

