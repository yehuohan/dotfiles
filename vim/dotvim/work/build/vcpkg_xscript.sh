#!/usr/bin/env bash

# Usage:
#     # set mirror, then run:
#     bash vcpkg_xscript.sh {url} {dst}

url=$1
dst=$2
sha512=$3
echo "X-Script.url:    ${url}"
echo "X-Script.dst:    ${dst}"
echo "X-Script.sha512: ${sha512}"

url=${url/https:\/\/github.com/https:\/\/<mirror>}
curl --progress-bar -L ${url} --create-dirs --output ${dst}
