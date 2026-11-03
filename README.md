# GetPatched recipe: libxml2

GetPatched maintains selected, tested security backports for package versions whose normal public support has ended. This repository contains the recipe and evidence inputs; it does not vendor a duplicate upstream source tree.

## Candidate targets

| Target ID | Pinned source | GetPatched version | CVE | State |
|---|---|---|---|---|
| `ubuntu-focal-amd64` | `2.9.10+dfsg-5ubuntu0.20.04.10` | `2.9.10+dfsg-5ubuntu0.20.04.10+getpatched1` | CVE-2025-49794, CVE-2025-49796 | Existing sponsor-first development candidate |
| `debian-bookworm-amd64` | `2.9.14+dfsg-1.3~deb12u6` | `2.9.14+dfsg-1.3~deb12u6+getpatched1` | CVE-2026-6653 | Local build and verification passed; hosted CI and public source PR pending |
| `debian-trixie-amd64` | `2.12.7+dfsg+really2.9.14-2.1+deb13u3` | `2.12.7+dfsg+really2.9.14-2.1+deb13u3+getpatched4` | CVE-2026-6653, CVE-2026-86144, CVE-2026-76781, CVE-2026-86141 | Development-verified for listed CVEs; unpublished, release pending |

The Debian targets are free and public-after-checks; no sponsor delay applies. They are unreleased candidates. No production package or signed APT index is published.

## Recipe structure and target support

package-manifest.json is the package index. Each target file holds its exact base, source publication, pinned .dsc and source archives, supported source versions, package version, binary names, patch IDs, and changelog entry. The platform repository's packages.json separately pins the target's build image, snapshot repositories, runner, scan ecosystem, release policy, and whether repository publication is supported.

A target ID names a distribution, release codename, and architecture, such as ubuntu-focal-amd64 or debian-bookworm-arm64. Add another target as a separate file under targets/<distribution>/<codename>-<architecture>.json, then add its independent platform profile and package policy. Ubuntu Focal amd64 is an existing development target. Both Debian targets passed policy-matched hosted verification for their claimed CVEs, with source recipe changes merged to the corresponding target branches. Platform catalogue metadata is in feature PR [#109](https://github.com/getpatched/platform/pull/109); it remains unmerged because merging to main deploys the Worker/site. Debian package publication is disabled; arm64 is not claimed.

The fetched source is the distribution's complete source package, including distro-specific packaging and existing patches. An upstream Git submodule alone would omit that state. Source files are pinned by URL, size, and SHA-256. For the Debian targets, signed Sources indexes authenticate the descriptor and source archive hashes; the individual .dsc uploader signatures have not been separately verified. The Ubuntu Focal descriptor has the existing limitation recorded in its target file.

## Patch and version policy

patches/metadata.json records each patch's purpose, checksum, upstream provenance, CVEs, regression tests, and appliesTo targets. An applicability entry may pin one exact source version or express inclusive/exclusive Debian-version bounds. The target's supportedSourceVersions remains an explicit allowlist: a version inside a patch range is not enough to build unless the target lists it and the build and regressions pass. Current patches are pinned to the exact version above.

The output version retains the full distribution source version and appends +getpatchedN. A new patch release from the same target base advances that target's serial; a changed distro source version gets its own reviewed target pin and release policy.

CVE-2025-49794-49796.patch adapts GNOME's Schematron lifetime and node-type checks for the pinned Focal source. It addresses CVE-2025-49794 and CVE-2025-49796, from upstream commit 81cef8c5 (https://gitlab.gnome.org/GNOME/libxml2/-/commit/81cef8c5b5aec2acdf5707e57a6db0c8d1d0abca). The pinned fixtures exercise both cases under Valgrind against the vulnerable baseline and installed patched package, followed by an xmllint consumer check.

CVE-2026-6653-debian.patch backports the parser EOF ownership and stop-loop changes needed by the pinned Bookworm and Trixie parser sources. Policy-matched hosted runs [41575270372](https://github.com/getpatched/platform/actions/runs/41575270372) and [41575930432](https://github.com/getpatched/platform/actions/runs/41575930432) passed exact-source builds, upstream tests, installed baseline use-after-free reproductions, patched installed regressions, candidate-only package-aware scans, `xmllint` consumer checks, and signed temporary APT-client checks. Both reports mark the candidates verified and release-ineligible because production publication is disabled. Raw Trivy 0.70.0 still reports CVE-2026-6653 on three libxml2 binaries per candidate without a GetPatched fixed version; this is disclosed and is not a Trivy-clean claim. Package source PR [#10](https://github.com/getpatched/packaging-libxml2/pull/10) is merged. No production package or signed index was published.

CVE-2026-86144 is a Debian Trixie-only development-verified fix; Bookworm is listed as postponed/minor and is not included. The patch adapts upstream GNOME commit `b63cd517afecb76582dd9488c55e54ceaf50de61` to Trixie's 2.9.14-based source. Hosted run [41626805158](https://github.com/getpatched/platform/actions/runs/41626805158) reproduced the baseline NULL read/SIGSEGV through both `xmlXIncludeProcess` and `xmlXIncludeProcessTree`; the patched installed package passed both checks. Package-aware scans cleared the target libxml2 findings, consumer checks passed, and an isolated signed APT client installed the binary and source packages. The candidate remains unpublished and release-ineligible.

CVE-2026-76781 is a Debian Trixie-only development-verified fix. Debian marks the pinned Trixie source vulnerable and Bookworm postponed/minor. It adapts upstream commit `a34c084d7a576914c1424caabdaaf5e227bb39ef` to the Trixie source tree. The installed-package regression loads a local catalog containing a valid `nextCatalog` entry followed by one missing its required `catalog` attribute, then verifies that the valid entry still resolves. Policy-matched hosted run [41633529746](https://github.com/getpatched/platform/actions/runs/41633529746) reproduced the baseline Valgrind read at address `0x30` and SIGSEGV, then passed on the `+getpatched3` package. The candidate is `candidateVerified=true` with checks passed; `releaseEligible=false` because publication is disabled. Package-aware before/after scans removed the target libxml2 findings; consumer compatibility and signed temporary APT binary/source installation also passed. Package PR [#12](https://github.com/getpatched/packaging-libxml2/pull/12) merged to `getpatched/debian-trixie`. No package or signed production index was published.

CVE-2026-86141 is a Debian Trixie-only development-verified fix. Debian's tracker marks the pinned source vulnerable and Bookworm fixed. It adapts upstream commit `e89a8aae4c9b40cdafcf66b3f9e57c62db37bb55` to Trixie's older 2.9.14 source, checking the `xmlStrdup` result before assigning it to the parser cursor. Hosted run [41692126745](https://github.com/getpatched/platform/actions/runs/41692126745) passed the exact-source build, installed baseline/patched regression, package-aware scans, consumer checks, and signed temporary APT client checks. The injected baseline allocation failure reproduced a NULL read and SIGSEGV; the patched package rejected the regexp cleanly with zero Memcheck errors. The candidate is verified for Trixie amd64 only and remains unreleased; publication is disabled. Raw Trivy still reports the four target libxml2 CVEs on the candidate packages, so do not describe it as Trivy-clean.

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
