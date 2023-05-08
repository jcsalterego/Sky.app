#!/usr/bin/env bash
#
# https://www.npmjs.com/package/create-dmg
# https://github.com/sindresorhus/create-dmg
#
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

create-dmg --overwrite "${app}" ${dir}

xcrun notarytool submit ${dir}*.dmg --keychain-profile "${keychain_profile}" --wait
xcrun stapler staple ${dir}*.dmg
spctl -a -vvvv -t open --context context:primary-signature --raw ${dir}*.dmg
