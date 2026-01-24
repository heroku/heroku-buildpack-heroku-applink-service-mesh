#!/usr/bin/env bash

set -euo pipefail

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

# Utility for downloading, verifying, and installing Heroku AppLink Service Mesh binary
install_applink_binary() {
    local install_dir="$1"
    local cached_etag="${2:-}"
    local arch
    local version
    local s3_bucket
    local binary_name
    local s3_url
    local current_etag

    arch=$(detect_arch)
    version="${HEROKU_APPLINK_SERVICE_MESH_RELEASE_VERSION:-latest}"
    s3_bucket="${HEROKU_APPLINK_SERVICE_MESH_S3_BUCKET:-heroku-applink-service-mesh-binaries}"
    binary_name="heroku-applink-service-mesh-${version}-${arch}"
    s3_url="https://${s3_bucket}.s3.amazonaws.com/${binary_name}"
    local well_known_binary_name="heroku-applink-service-mesh"

    # Get current ETag from S3
    current_etag=$(curl -sI "$s3_url" 2>/dev/null | grep -i '^etag:' | sed 's/^etag: *//i' | tr -d '"' | tr -d '\r' || echo "")
    export APPLINK_CURRENT_ETAG="$current_etag"

    # Check if we can reuse existing binary
    if [ -n "$cached_etag" ] && [ -n "$current_etag" ] && \
       [ "$cached_etag" = "$current_etag" ] && \
       [ -f "$install_dir/$well_known_binary_name" ]; then
        echo "-----> Reusing cached Heroku AppLink Service Mesh"
        return 0
    fi

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
    echo "-----> Installing Heroku AppLink Service Mesh for $arch..."
    echo "       Downloading $binary_name..."
    local current_dir
    current_dir=$(pwd)
    cd "$install_dir"

    # Download binary, signature and public key
    curl -JLs "$s3_url" -o "$binary_name"
    curl -JLs "$asc_url" -o "${binary_name}.asc"
    curl -JLs "$pubkey_url" -o "public-key.asc"

    # Import public key
    echo "       Importing public key..."
    gpg --import public-key.asc

    # Verify signature
    echo "       Verifying binary signature..."
    if ! gpg --verify "${binary_name}.asc" "$binary_name"; then
        echo " !     Binary signature verification failed!" >&2
        cd "$current_dir"
        return 1
    fi

    cd "$current_dir"

    # Install binary
    if [ ! -f "$install_dir/$binary_name" ]; then
        echo " !     Heroku AppLink Service Mesh binary not found at $install_dir/$binary_name!" >&2
        return 1
    fi

    echo "       Installing $binary_name..."
    chmod +x "$install_dir/$binary_name"

    # Create symlink for well-known name
    ln -sf "$binary_name" "$install_dir/$well_known_binary_name"

    # Cleanup
    rm -f "$install_dir/public-key.asc" "${install_dir}/${binary_name}.asc"

    echo "       Done!"

    return 0
}
