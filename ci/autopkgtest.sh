#!/usr/bin/env bash
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
descriptors=(/originals/*.dsc)
test "${#descriptors[@]}" -eq 1
dpkg-source -x "${descriptors[0]}" "$work/source"

# Run Debian's C consumer test directly. Its control stanza also declares
# dependencies for the Python bindings, which this recipe does not ship.
cd "$work/source"
sh debian/tests/build
printf 'build PASS\n' > /reports/autopkgtest-summary.txt
