#!/usr/bin/env bash
set -euo pipefail

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cc -std=c99 -Wall -Wextra -Werror -I/usr/include/libxml2 /recipe/ci/compatibility.c -lxml2 -o "$work/consumer"
"$work/consumer"
