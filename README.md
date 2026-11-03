# GetPatched recipe: libxml2

GetPatched maintains selected, tested security backports for package versions whose normal public support has ended. This repository contains the recipe and evidence inputs; it does not vendor a duplicate upstream source tree.

## Candidate targets

| Target ID | Pinned source | GetPatched version | CVE | State |
|---|---|---|---|---|
| `ubuntu-focal-amd64` | `2.9.10+dfsg-5ubuntu0.20.04.10` | `2.9.10+dfsg-5ubuntu0.20.04.10+getpatched1` | CVE-2025-49794, CVE-2025-49796 | Existing sponsor-first development candidate |
| `debian-bookworm-amd64` | `2.9.14+dfsg-1.3~deb12u6` | `2.9.14+dfsg-1.3~deb12u6+getpatched1` | CVE-2026-6653 | Local build and verification passed; hosted CI and public source PR pending |
| `debian-trixie-amd64` | `2.12.7+dfsg+really2.9.14-2.1+deb13u3` | `2.12.7+dfsg+really2.9.14-2.1+deb13u3+getpatched2` | CVE-2026-6653, CVE-2026-86144 | New candidate; CVE-2026-6653 +getpatched1 remains previously verified in [run 41575930432](https://github.com/getpatched/platform/actions/runs/41575930432) |

The Debian targets are free and public-after-checks; no sponsor delay applies. They are unreleased candidates. No production package or signed APT index is published.

## Recipe structure and target support

package-manifest.json is the package index. Each target file holds its exact base, source publication, pinned .dsc and source archives, supported source versions, package version, binary names, patch IDs, and changelog entry. The platform repository's packages.json separately pins the target's build image, snapshot repositories, runner, scan ecosystem, release policy, and whether repository publication is supported.

A target ID names a distribution, release codename, and architecture, such as ubuntu-focal-amd64 or debian-bookworm-arm64. Add another target as a separate file under targets/<distribution>/<codename>-<architecture>.json, then add its independent platform profile and package policy. Ubuntu Focal amd64 is an existing development target. The Debian targets have passed their local exact-source package builds, installed regressions, before/after scans, consumer checks, and signed temporary APT client tests. They remain unverified in platform policy pending hosted CI and public source PR integration. Debian package publication is disabled; arm64 is not claimed.

The fetched source is the distribution's complete source package, including distro-specific packaging and existing patches. An upstream Git submodule alone would omit that state. Source files are pinned by URL, size, and SHA-256. For the Debian targets, signed Sources indexes authenticate the descriptor and source archive hashes; the individual .dsc uploader signatures have not been separately verified. The Ubuntu Focal descriptor has the existing limitation recorded in its target file.

## Patch and version policy

patches/metadata.json records each patch's purpose, checksum, upstream provenance, CVEs, regression tests, and appliesTo targets. An applicability entry may pin one exact source version or express inclusive/exclusive Debian-version bounds. The target's supportedSourceVersions remains an explicit allowlist: a version inside a patch range is not enough to build unless the target lists it and the build and regressions pass. Current patches are pinned to the exact version above.

The output version retains the full distribution source version and appends +getpatchedN. A new patch release from the same target base advances that target's serial; a changed distro source version gets its own reviewed target pin and release policy.

CVE-2025-49794-49796.patch adapts GNOME's Schematron lifetime and node-type checks for the pinned Focal source. It addresses CVE-2025-49794 and CVE-2025-49796, from upstream commit 81cef8c5 (https://gitlab.gnome.org/GNOME/libxml2/-/commit/81cef8c5b5aec2acdf5707e57a6db0c8d1d0abca). The pinned fixtures exercise both cases under Valgrind against the vulnerable baseline and installed patched package, followed by an xmllint consumer check.

CVE-2026-6653-debian.patch backports the parser EOF ownership and stop-loop changes needed by the pinned Bookworm and Trixie parser sources. The regression inputs include Launchpad's public XML fixture and the checked-in Chromium-derived fuzz harness. The source-level preflight built each exact distro source with AddressSanitizer: both pristine baselines reproduced a heap use-after-free in `xmlParseInternalSubset`, and both patched builds exited cleanly. The full local package pipelines also passed for both targets: installed Valgrind baseline/patched checks, package-aware before/after scans, raw Trivy and OSV capture, and signed temporary APT client verification. Raw Trivy 0.70 still reports CVE-2026-6653 after patching because its Debian records do not define a GetPatched fixed version; this remains visible in the retained raw reports and is not a Trivy-clean claim. Hosted CI and public source PR integration remain required before these candidates can count as verified. The local evidence record is maintained in the platform worktree and will be linked after that branch is published.

CVE-2026-86144 is a Debian Trixie-only development candidate. Debian's tracker currently marks the pinned Trixie source vulnerable; Bookworm is listed as postponed/minor and is not included. The patch adapts upstream GNOME commit `b63cd517afecb76582dd9488c55e54ceaf50de61` to Trixie's 2.9.14-based source. A loopback-only regression exercises both `xmlXIncludeProcess` and `xmlXIncludeProcessTree`: the exact installed baseline must contact the local listener despite `XML_PARSE_NONET`, while the patched package must not. This target is not verified or publicly advertised until the exact installed baseline/patched checks, package build, consumer compatibility, package-aware scans, and signed temporary APT client checks pass.

## Sponsorship and licensing

Every active individual GitHub Sponsors tier grants access to official early-channel binaries for the Focal sponsor-first target; there is no tier allowlist or minimum amount. The Debian candidates have no sponsor delay and are intended to be public after their checks pass. A one-time sponsorship qualifies only while GitHub reports it active. Organization sponsorships are not yet supported because the service cannot securely map one to a specific GitHub user; organization membership alone never grants access. Access ends when GitHub reports the sponsorship inactive. Early binaries may be used privately and commercially, but may not be redistributed, sublicensed, mirrored, or shared before public release. Preserve the applicable Ubuntu or Debian source copyright file from `LICENSES/SOURCE-COPYRIGHTS.md` together with the upstream component licenses.

GetPatched-authored recipes, patches, tests, and documentation are MIT-licensed from day one. Anyone may build from public source and redistribute an independent build under MIT and applicable third-party licenses. The MIT file does not replace upstream or distro copyright and licensing obligations in the source or compiled package. Preserve the source notices linked from `LICENSES/SOURCE-COPYRIGHTS.md` and comply with each included component's license. The regression harness retains its Chromium BSD-3-Clause notice; the public PoC fixture is attributed separately and no license is asserted for it.

## Build and verification

From a clean checkout on a disposable Linux Docker host:

    git clone https://github.com/getpatched/platform.git
    git -C platform checkout d0b53ed9d3eb2ae43f9fbb3d4ac20b7036207dd3
    git clone --branch getpatched/debian-bookworm https://github.com/getpatched/packaging-libxml2.git packaging-libxml2-bookworm
    python3 platform/scripts/build-package.py --source packaging-libxml2-bookworm --target debian-bookworm-amd64 --output build/libxml2-bookworm

For Trixie, check out its target branch and use the same pinned platform revision:

    git clone --branch getpatched/debian-trixie https://github.com/getpatched/packaging-libxml2.git packaging-libxml2-trixie
    python3 platform/scripts/build-package.py --source packaging-libxml2-trixie --target debian-trixie-amd64 --output build/libxml2-trixie

The builder consumes the target's pinned inputs, runs baseline and patched installed-package checks, retains scan evidence, and tests signed APT installation of the binary and source packages. It does not publish binaries. Ubuntu Pro/ESM compatibility is not tested or claimed. The prior full-source snapshot remains on the legacy branch: https://github.com/getpatched/packaging-libxml2/tree/legacy
