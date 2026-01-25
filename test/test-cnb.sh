#!/usr/bin/env bash

set -euo pipefail

BUILDER_TAG="${1:-24}"
ARCH="${2:-arm64}"
FIXTURE=${FIXTURE:-test/fixtures/empty}

BUILDER="heroku/builder:${BUILDER_TAG}"
PLATFORM="linux/${ARCH}"

OUTPUT_IMAGE="applink-cnb-test"

pack build "${OUTPUT_IMAGE}" \
    --builder "${BUILDER}" \
    --platform "${PLATFORM}" \
    --buildpack ./ \
    --trust-extra-buildpacks \
    --path "${FIXTURE}"
