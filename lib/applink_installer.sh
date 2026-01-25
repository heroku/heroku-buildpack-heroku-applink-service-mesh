#!/usr/bin/env bash

set -euo pipefail

export APPLINK_WELL_KNOWN_BINARY_NAME="heroku-applink-service-mesh"

# Detect and normalize architecture
detect_arch() {
    local arch
    arch=$(uname -m)
    if [ "$arch" = "x86_64" ]; then
        echo "amd64"
    elif [ "$arch" = "aarch64" ]; then
        echo "arm64"
    else
        echo " !     Unsupported architecture: $arch" >&2
        return 1
    fi
}

# Get S3 URL for the binary
get_s3_url() {
    local arch
    arch=$(detect_arch)
    local version="${HEROKU_APPLINK_SERVICE_MESH_RELEASE_VERSION:-latest}"
    local s3_bucket="${HEROKU_APPLINK_SERVICE_MESH_S3_BUCKET:-heroku-applink-service-mesh-binaries}"
    local binary_name="${APPLINK_WELL_KNOWN_BINARY_NAME}-${version}-${arch}"
    echo "https://${s3_bucket}.s3.amazonaws.com/${binary_name}"
}

# Utility for downloading, verifying, and installing Heroku AppLink Service Mesh binary
install_applink_binary() {
    local install_dir="$1"

    local s3_url
    s3_url=$(get_s3_url)

    local asc_url="${s3_url}.asc"
    local pubkey_url="https://heroku-applink-service-mesh-binaries.s3.amazonaws.com/public-key.asc"

    # Create installation directory
    mkdir -p "$install_dir"

    # Require gpg
    if ! command -v gpg > /dev/null; then
        echo " !     gpg is not installed!" >&2
        echo " !     Ensure the app is on the latest Heroku stack" >&2
        return 1
    fi

    # Download and verify
    echo "-----> Installing Heroku AppLink Service Mesh"
    echo "       Downloading ${APPLINK_WELL_KNOWN_BINARY_NAME}"
    local current_dir
    current_dir=$(pwd)
    cd "$install_dir"

    # Download binary, signature and public key
    curl -JLs "$s3_url" -o "$APPLINK_WELL_KNOWN_BINARY_NAME"
    curl -JLs "$asc_url" -o "${APPLINK_WELL_KNOWN_BINARY_NAME}.asc"
    curl -JLs "$pubkey_url" -o "public-key.asc"

    # Import public key
    echo "       Importing public key..."
    gpg --import public-key.asc

    # Verify signature
    echo "       Verifying binary signature..."
    if ! gpg --verify "${APPLINK_WELL_KNOWN_BINARY_NAME}.asc" "$APPLINK_WELL_KNOWN_BINARY_NAME"; then
        echo " !     Binary signature verification failed!" >&2
        cd "$current_dir"
        return 1
    fi

    cd "$current_dir"

    # Install binary
    if [ ! -f "$install_dir/$APPLINK_WELL_KNOWN_BINARY_NAME" ]; then
        echo " !     Heroku AppLink Service Mesh binary not found at $install_dir/$APPLINK_WELL_KNOWN_BINARY_NAME!" >&2
        return 1
    fi

    echo "       Installing..."
    chmod +x "$install_dir/$APPLINK_WELL_KNOWN_BINARY_NAME"

    # Cleanup
    rm -f "$install_dir/public-key.asc" "${install_dir}/${APPLINK_WELL_KNOWN_BINARY_NAME}.asc"

    echo "       Done!"
}
