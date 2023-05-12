#!/bin/bash

new_version="${1}"
if [ -z "${new_version}" ]; then
    echo "usage: $0 <new_version>" >&2
    exit 1
fi

version=$(./get-version.sh)
echo "current version: ${version}"
echo "    new version: ${new_version}"

# Update Info.plist
sed -i '' -e 's;'${version}';'${new_version}';g' ../Sky/Info.plist

if [ -z "$(echo ${new_version} | grep 'pre')" ]; then
    # production release things

    # markdown in sed? what a country!
    markdown='The current release is [**'${new_version}'**](https://github.com/jcsalterego/Sky.app/releases/latest).'
    sed -i '' \
        -e 's^The current release is .*^'"${markdown}"'^g' \
        ../README.md

    sed -i '' \
        -e 's^'${version}'^'${new_version}'^g' \
        ../README.md
fi

git diff
