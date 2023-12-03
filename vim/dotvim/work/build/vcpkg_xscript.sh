#!/usr/bin/env bash

url=$1
sha512=$2
dst=$3
echo "X-Script.url:    ${url}"
echo "X-Script.dsr:    ${sha512}"
echo "X-Script.sha512: ${dst}"

curl --progress-bar -L ${url/https:\/\/github.com/https:\/\/kkgithub.com} --create-dirs --output ${dst}
