#!/usr/bin/env bash
#
# CNB buildpack test script
#
# Usage: test/test-cnb.sh [HEROKU_BUILDER] [ARCH] [FIXTURE]
#   HEROKU_BUILDER: Heroku builder (default: builder:24)
#   ARCH: Architecture to test (default: arm64)
#   FIXTURE: Test fixture directory (default: test/fixtures/procfile_with_web_using_applink)
#
# This basic script builds a test image twice to help verify:
# - Initial build downloads and installs the AppLink binary
# - Run the `heroku-applink-service-mesh` on the output image
# - Rebuild reuses the cached binary (ETag-based caching)
#
# TODO: Implement more comprehensive testing:
# - Assert specific output messages (e.g., "Reusing cached" on rebuild, Procfile validation output, etc)
# - Test caching behavior when the ARCH changes
# - Test behavior when changing HEROKU_APPLINK_SERVICE_MESH_RELEASE_VERSION

set -euo pipefail

HEROKU_BUILDER="${1:-builder:24}"
ARCH="${2:-arm64}"
FIXTURE="${3:-test/fixtures/procfile_with_web_using_applink}"

BUILDER="heroku/${HEROKU_BUILDER}"
PLATFORM="linux/${ARCH}"

OUTPUT_IMAGE="applink-cnb-test"

output::info() {
	local ansi_blue=$'\e[1;34m'
	local ansi_reset=$'\e[0m'
	echo -e "${ansi_blue}$*${ansi_reset}"
}

remove_image() {
	# shellcheck disable=SC2312 # Intentional: docker command in test condition to check image existence
	if [[ -n "$(docker images -q "${OUTPUT_IMAGE}")" ]]; then
		output::info "Removing test output image '${OUTPUT_IMAGE}'"
		docker rmi "${OUTPUT_IMAGE}" &>/dev/null || true
	fi
}

run_build() {
	output::info "Running pack to build '${FIXTURE}' with CNB using '${BUILDER}' on '${PLATFORM}'"
	pack build "${OUTPUT_IMAGE}" \
		--builder "${BUILDER}" \
		--platform "${PLATFORM}" \
		--buildpack ./ \
		--trust-extra-buildpacks \
		--path "${FIXTURE}"

	output::info "Running 'heroku-applink-service-mesh -v' on output image '${OUTPUT_IMAGE}'"
	docker run \
		--rm "${OUTPUT_IMAGE}" \
		-- heroku-applink-service-mesh -v

	output::info "Running 'heroku-applink-service-mesh-latest-${ARCH} -v' on output image '${OUTPUT_IMAGE}'"
	docker run \
		--rm "${OUTPUT_IMAGE}" \
		-- "heroku-applink-service-mesh-latest-${ARCH}" -v
}

remove_image

run_build

output::info "Rebuild to test caching"
run_build

remove_image
