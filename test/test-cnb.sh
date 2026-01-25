#!/usr/bin/env bash

set -euo pipefail

BUILDER_TAG="${1:-24}"
ARCH="${2:-arm64}"
FIXTURE=${FIXTURE:-test/fixtures/procfile_with_web_using_applink}

BUILDER="heroku/builder:${BUILDER_TAG}"
PLATFORM="linux/${ARCH}"

OUTPUT_IMAGE="applink-cnb-test"

remove_image() {
    if [ ! -z "$(docker images -q ${OUTPUT_IMAGE})" ]; then
        echo "Removing test output image '${OUTPUT_IMAGE}'"
        docker rmi "${OUTPUT_IMAGE}" &> /dev/null || true
    fi
}

run_build() {
    echo "Running pack to build '${FIXTURE}' with CNB using '${BUILDER}' on '${PLATFORM}'"
    pack build "${OUTPUT_IMAGE}" \
        --builder "${BUILDER}" \
        --platform "${PLATFORM}" \
        --buildpack ./ \
        --trust-extra-buildpacks \
        --path "${FIXTURE}"

    echo "Running 'heroku-applink-service-mesh -v' on output image '${OUTPUT_IMAGE}'"
    docker run \
        --rm "$OUTPUT_IMAGE" \
        -- heroku-applink-service-mesh -v
}

remove_image

run_build

echo "Rebuild to test caching"
run_build

remove_image
