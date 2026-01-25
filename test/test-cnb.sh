#!/usr/bin/env bash

set -euo pipefail

BUILDER_TAG="${1:-24}"
ARCH="${2:-arm64}"
FIXTURE="${3:-test/fixtures/procfile_with_web_using_applink}"

BUILDER="heroku/builder:${BUILDER_TAG}"
PLATFORM="linux/${ARCH}"

OUTPUT_IMAGE="applink-cnb-test"

output::test_step() {
    local ansi_blue=$'\e[1;34m'
    local ansi_reset=$'\e[0m'
    echo -e "${ansi_blue}$*${ansi_reset}"
}

remove_image() {
    if [ ! -z "$(docker images -q ${OUTPUT_IMAGE})" ]; then
        output::test_step "Removing test output image '${OUTPUT_IMAGE}'"
        docker rmi "${OUTPUT_IMAGE}" &> /dev/null || true
    fi
}

run_build() {
    output::test_step "Running pack to build '${FIXTURE}' with CNB using '${BUILDER}' on '${PLATFORM}'"
    pack build "${OUTPUT_IMAGE}" \
        --builder "${BUILDER}" \
        --platform "${PLATFORM}" \
        --buildpack ./ \
        --trust-extra-buildpacks \
        --path "${FIXTURE}"

    output::test_step "Running 'heroku-applink-service-mesh -v' on output image '${OUTPUT_IMAGE}'"
    docker run \
        --rm "$OUTPUT_IMAGE" \
        -- heroku-applink-service-mesh -v
}

remove_image

run_build

output::test_step "Rebuild to test caching"
run_build

remove_image
