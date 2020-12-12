#!/usr/bin/env bash

set -e

DOCKER_REGISTRY=${DOCKER_REGISTRY:="localhost:5000"}

export $(grep -v '^#' ../.env | xargs -d '\n')

find -path './*' -type d | while IFS= read -r FILE; do
  TAG=$(basename "$FILE")

  echo "Building $FILE..."

  docker image build --build-arg GOCD_VERSION=$GOCD_VERSION -f $FILE/Dockerfile -t $DOCKER_REGISTRY/$TAG:$GOCD_VERSION .
  docker image push $DOCKER_REGISTRY/$TAG:$GOCD_VERSION
done

