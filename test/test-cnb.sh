#!/usr/bin/env bash

set -euo pipefail

BUILDER_TAG="${1:-24}"
ARCH="${2:-arm64}"

OUTPUT_IMAGE="applink-cnb-test"

pack build "${OUTPUT_IMAGE}" \
    --builder "heroku/builder:${BUILDER_TAG}" \
    --platform "linux/${ARCH}" \
    --buildpack ./ \
    --trust-extra-buildpacks