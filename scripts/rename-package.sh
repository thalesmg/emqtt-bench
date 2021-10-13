#!/usr/bin/env bash

set -euo pipefail

cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

if [ "$(uname -s)" = 'Darwin' ]; then
    DIST='macos'
    VERSION_ID=$(sw_vers | gsed -n '/^ProductVersion:/p' | gsed -r 's/ProductVersion:(.*)/\1/g' | gsed -r 's/([0-9]+).*/\1/g' | gsed 's/^[ \t]*//g')
    SYSTEM="$(echo "${DIST}${VERSION_ID}" | gsed -r 's/([a-zA-Z]*)-.*/\1/g')"
elif [ "$(uname -s)" = 'Linux' ]; then
    if grep -q -i 'centos' /etc/*-release; then
        DIST='centos'
        VERSION_ID="$(rpm --eval '%{centos_ver}')"
    else
        DIST="$(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/"//g')"
        VERSION_ID="$(sed -n '/^VERSION_ID=/p' /etc/os-release | sed -r 's/VERSION_ID=(.*)/\1/g' | sed 's/"//g')"
    fi
    SYSTEM="$(echo "${DIST}${VERSION_ID}" | sed -r 's/([a-zA-Z]*)-.*/\1/g')"
fi

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)
        ARCH='amd64'
        ;;
    aarch64)
        ARCH='arm64'
        ;;
    arm*)
        ARCH=arm
        ;;
esac

VSN="$(grep -E ".+vsn.+" _build/emqtt_bench/lib/emqtt_bench/ebin/emqtt_bench.app | cut -d '"' -f2)"
BASE=$(find ./_build/emqtt_bench/rel/emqtt_bench -name "*.tar.gz" | tail -1)
cp "$BASE" "./emqtt-bench-${VSN}-${SYSTEM}-${ARCH}.tar.gz"
