#!/usr/bin/env bash
#
# https://www.npmjs.com/package/create-dmg
# https://github.com/sindresorhus/create-dmg
#
load_secret() {
    secret_name="${1}"
    jq -r ".\"${secret_name}\"" .secrets.json
}

dir=../Build/Releases/
mkdir -p ${dir}

if [ -z "$1" ]; then
    echo "usage: <app path>"
    exit 1
fi

app="${1}"

if [ ! -f ~/.config/xcode ]; then
    echo "requires ~/.config/xcode"
    exit 1
fi
keychain_profile="$(awk '/keychain-profile/ { print $NF }' ~/.config/xcode)"
if [ -z "${keychain_profile}" ]; then
    echo "needs keychain profile"
    exit 1
fi

echo ${1}
rm -rf ${dir}
mkdir -p ${dir}
set -e
set -x

create-dmg --no-code-sign --overwrite "${app}" ${dir}
dmg="$(cd ${dir}; realpath *.dmg)"
echo "DMG: ${dmg}"

apple_id=$(load_secret 'apple-id')
password=$(load_secret 'app-password')
team_id=$(load_secret 'team-id')

xcrun notarytool submit "${dmg}" \
  --wait \
  --apple-id "${apple_id}" \
  --password "${password}" \
  --team-id "${team_id}" \
;
xcrun stapler staple "${dmg}";
xcrun stapler validate "${dmg}";
