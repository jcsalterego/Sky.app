#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "usage: $0 [profile-name]" >&2
    echo "env: APPLE_ID APPLE_APP_PASSWORD APPLE_TEAM_ID" >&2
}

profile_name="${1:-notary-profile}"
config_dir="$HOME/.config"
config_path="$config_dir/xcode"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if ! command -v xcrun >/dev/null 2>&1; then
    echo "xcrun is not installed or not on PATH." >&2
    exit 1
fi

mkdir -p "$config_dir"
printf 'keychain-profile = %s\n' "$profile_name" > "$config_path"

store_args=("$profile_name" "--validate")

if [ -n "${APPLE_ID:-}" ]; then
    store_args+=("--apple-id" "$APPLE_ID")
fi

if [ -n "${APPLE_APP_PASSWORD:-}" ]; then
    store_args+=("--password" "$APPLE_APP_PASSWORD")
fi

if [ -n "${APPLE_TEAM_ID:-}" ]; then
    store_args+=("--team-id" "$APPLE_TEAM_ID")
fi

xcrun notarytool store-credentials "${store_args[@]}"

echo "Stored notary profile: $profile_name"
echo "Config updated: $config_path"
