#!/usr/bin/env bash
set -euo pipefail
value=$(printf '%s\n' '<root><item>value</item></root>' | xmllint --xpath 'string(/root/item)' -)
test "$value" = value
