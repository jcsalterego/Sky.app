#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "usage: $0 path/to/Sky.app [output-dir]" >&2
}

resolve_notary_keychain_profile() {
  if [ -n "${NOTARY_KEYCHAIN_PROFILE:-}" ]; then
    echo "$NOTARY_KEYCHAIN_PROFILE"
    return 0
  fi

  if [ -f "$HOME/.config/xcode" ]; then
    awk '/keychain-profile/ { print $NF }' "$HOME/.config/xcode"
  fi
}

store_notary_credentials_if_configured() {
  local profile_name="$1"

  if [ -z "$profile_name" ]; then
    return 0
  fi

  if [ -z "${APPLE_ID:-}" ] || [ -z "${APPLE_APP_PASSWORD:-}" ] || [ -z "${APPLE_TEAM_ID:-}" ]; then
    return 0
  fi

  xcrun notarytool store-credentials "$profile_name" \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_PASSWORD" \
    --team-id "$APPLE_TEAM_ID" \
    --validate
}

resolve_codesign_identity() {
  if [ -n "${DMG_CODESIGN_IDENTITY:-}" ]; then
    echo "$DMG_CODESIGN_IDENTITY"
    return 0
  fi

  local identities
  identities="$(
    security find-identity -v -p codesigning \
      | awk '/Developer ID Application:/ {print $2}'
  )"

  if [ -z "$identities" ]; then
    echo "no Developer ID Application signing identity found" >&2
    exit 1
  fi

  echo "$identities" | head -n 1
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

app_path="$1"
output_dir="${2:-../Build/Releases}"

if [ ! -d "$app_path" ]; then
  echo "app not found: $app_path" >&2
  exit 1
fi

if [[ "$app_path" != *.app ]]; then
  echo "expected a macOS .app bundle: $app_path" >&2
  exit 1
fi

if ! command -v create-dmg >/dev/null 2>&1; then
  echo "create-dmg is not installed or not on PATH." >&2
  echo "Install it with: npm install -g create-dmg" >&2
  exit 1
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun is not installed or not on PATH." >&2
  exit 1
fi

mkdir -p "$output_dir"

probe_path="$output_dir/.build-dmg-write-test"
if ! : > "$probe_path" 2>/dev/null; then
  echo "output directory is not writable: $output_dir" >&2
  exit 1
fi
rm -f "$probe_path"

create-dmg --overwrite --no-code-sign "$app_path" "$output_dir"

dmg_path="$(find "$output_dir" -maxdepth 1 -name '*.dmg' -print -quit)"
if [ -z "$dmg_path" ]; then
  echo "create-dmg finished, but no DMG was found in $output_dir" >&2
  exit 1
fi

codesign_identity="$(resolve_codesign_identity)"
codesign --sign "$codesign_identity" --timestamp "$dmg_path"
codesign --verify --verbose=2 "$dmg_path"

notary_profile="$(resolve_notary_keychain_profile)"
store_notary_credentials_if_configured "$notary_profile"
if [ -n "$notary_profile" ]; then
  xcrun notarytool submit "$dmg_path" --wait --keychain-profile "$notary_profile"
else
  if [ -z "${APPLE_ID:-}" ] || [ -z "${APPLE_APP_PASSWORD:-}" ] || [ -z "${APPLE_TEAM_ID:-}" ]; then
    echo "missing notarization credentials; set NOTARY_KEYCHAIN_PROFILE or APPLE_ID, APPLE_APP_PASSWORD, and APPLE_TEAM_ID" >&2
    exit 1
  fi

  xcrun notarytool submit "$dmg_path" \
    --wait \
    --apple-id "$APPLE_ID" \
    --password "$APPLE_APP_PASSWORD" \
    --team-id "$APPLE_TEAM_ID"
fi

xcrun stapler staple "$dmg_path"
xcrun stapler validate "$dmg_path"

echo "DMG: $(cd "$(dirname "$dmg_path")" && pwd)/$(basename "$dmg_path")"
echo "Code signing identity: $codesign_identity"
if [ -n "$notary_profile" ]; then
  echo "Notary profile: $notary_profile"
fi
