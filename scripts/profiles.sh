#!/usr/bin/env bash

set -e

PROFILES_FILE=${PROFILES_FILE:="./scripts/profiles.txt"}
GO_SERVER_IP=$(ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{ print $1 }')

source $(dirname $0)/common.sh

elastic_cluster_profiles_payload() {
  cat <<EOF
{
  "id": "$CLUSTER_PROFILE_ID",
  "plugin_id": "cd.go.contrib.elastic-agent.docker",
  "properties": [
    {
      "key": "go_server_url",
      "value": "$GO_SERVER_URL_HTTPS"
    },
    {
      "key": "environment_variables",
      "value": "GO_EA_SERVER_URL=$GO_SERVER_URL_HTTP"
    },
    {
      "key": "max_docker_containers",
      "value": "60"
    },
    {
      "key": "docker_uri",
      "value": "http://$DOCKER_DIND_HOSTNAME:2375"
    },
    {
      "key": "auto_register_timeout",
      "value": "3"
    }
  ]
}
EOF
}

elastic_profiles_payload() {
  local GOCD_AGENT_NAME="$1"
  local GOCD_AGENT_IMAGE="$2"
  local GOCD_AGENT_PRIVILEGED="$3"

  cat <<EOF
{
  "id": "$GOCD_AGENT_NAME",
  "cluster_profile_id": "$CLUSTER_PROFILE_ID",
  "properties": [
    {
      "key": "Hosts",
      "value": "$GO_SERVER_IP $DOCKER_GO_HOSTNAME\n"
    },
    {
      "key": "Mounts",
      "value": "/home/go/.ssh:/home/go/.ssh:ro"
    },
    {
      "key": "Image",
      "value": "$GOCD_AGENT_IMAGE:$GOCD_VERSION"
    },
    {
      "key": "Privileged",
      "value": "$GOCD_AGENT_PRIVILEGED"
    }
  ]
}
EOF
}

create_profiles() {
  local FILE="$1"

  if [ -f "$FILE" ]; then
    while IFS= read -r PROFILE; do
      if [ -z "$PROFILE" ]; then
        return
      fi

      local AGENT_NAME=$(echo "$PROFILE" | awk '{ print $1 }')
      local AGENT_IMAGE=$(echo "$PROFILE" | awk '{ print $2 }')
      local AGENT_PRIVILEGED=$(echo "$PROFILE" | awk '{ print $3 }')

      echo "Creating elastic profile $AGENT_NAME."

      curl --silent -i "$GO_SERVER_URL_HTTP/api/elastic/profiles" \
        -H 'Accept: application/vnd.go.cd.v2+json' \
        -H 'Content-Type: application/json' \
        -X POST -d "$(elastic_profiles_payload "$AGENT_NAME" "$AGENT_IMAGE" "$AGENT_PRIVILEGED")"
    done < "$FILE"
  else
    echo "File $FILE not found." 2>&1
  fi
}

echo "Creating cluster profile $GO_CLUSTER_PROFILE_ID."

curl --silent -i "$GO_SERVER_URL_HTTP/api/admin/elastic/cluster_profiles" \
  -H 'Accept: application/vnd.go.cd.v1+json'  \
  -H 'Content-Type: application/json' \
  -X POST -d "$(elastic_cluster_profiles_payload)"

echo "Creating elastic profiles..."

create_profiles "$PROFILES_FILE"

