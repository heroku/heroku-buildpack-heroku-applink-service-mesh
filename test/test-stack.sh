#!/usr/bin/env bash

set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: $0 STACK"; exit 1; }

STACK="${1}"
BASE_IMAGE="heroku/${STACK/-/:}-build"
OUTPUT_IMAGE="applink-buildpack-test-${STACK}"

echo "Building applinkbuildpack on stack ${STACK}..."

docker build \
    --build-arg STACK="$STACK" \
    --build-arg BASE_IMAGE="$BASE_IMAGE" \
    --build-arg REPO_OWNER="${REPO_OWNER:-heroku}" \
    --build-arg REPO_PROJECT="${REPO_PROJECT:-heroku-applink-service-mesh}" \
    -t "$OUTPUT_IMAGE" \
    .
