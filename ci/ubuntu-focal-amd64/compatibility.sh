#!/usr/bin/env bash
set -euo pipefail

xml='<record xmlns="urn:example:record" id="42"/>'
value=$(printf '%s\n' "$xml" | xmllint --nonet --xpath \
  'string(/*[local-name()="record" and namespace-uri()="urn:example:record"]/@id)' -)
test "$value" = 42
