#!/bin/bash

grep -A1 CFBundleVersion ../Sky/Info.plist \
    | grep '<string>' \
    | awk '/string/{print $1}' \
    | sed -e 's,<[/]*string>,,g'
