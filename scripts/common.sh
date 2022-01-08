#!/usr/bin/env bash

set -e

DOCKER_GO_HOSTNAME=${DOCKER_GO_HOSTNAME:="gocd-server"}
DOCKER_DIND_HOSTNAME=${DOCKER_DIND_HOSTNAME:="docker"}
CLUSTER_PROFILE_ID=${GO_CLUSTER_PROFILE_ID:="dev"}

GO_SERVER_URL_HTTP="http://$DOCKER_GO_HOSTNAME:8153/go"
GO_SERVER_URL_HTTPS="https://$DOCKER_GO_HOSTNAME:8153/go"

parse_property() {
  local PROPERTY="$1"
  local JSONPATH="$2"

  python3 scripts/parse.py "$PROPERTY" "$JSONPATH"
}

wait_server_ready() {
  printf '\e[31m%s\e[0m' "Waiting for GoCD server"

  while true; do
    local STATUS_CODE=$(curl --silent "$GO_SERVER_URL_HTTP/api/v1/health" -o /dev/null -w "%{http_code}")

    if [ "$STATUS_CODE" == "200" ]; then
      break
    fi

    printf '\e[31m%s\e[0m' "."
    sleep 3
  done

  echo -e "\n\e[0m"
}

wait_server_ready

