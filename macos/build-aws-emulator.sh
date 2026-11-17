#!/usr/bin/env bash
# Builds the macOS arm64 aws-emulator release archive for the tap's GitHub release.
# Upstream publishes Linux packages only, so this tap builds macOS from the upstream tag
# with one patch (aws-emulator-run-memory.patch).
#
# Usage: macos/build-aws-emulator.sh <version> <release-date YYYY.MM.DD> [work-dir]
# Needs: Rust (cargo), Xcode Command Line Tools, about 25 GB of disk and 24 GB of RAM.
set -euo pipefail

version="${1:?version, for example 1.0.481}"
release_date="${2:?release date, for example 2026.11.16}"
work="${3:-${TMPDIR:-/tmp}/aws-emulator-build}"
here="$(cd "$(dirname "$0")" && pwd)"

os="$(uname -s)"
arch="$(uname -m)"
[[ "${os}-${arch}" == "Darwin-arm64" ]] || {
  echo "Run this on macOS arm64." >&2
  exit 1
}

mkdir -p "${work}"
src="${work}/src-${version}"
if [[ ! -d "${src}" ]]
then
  git clone --quiet --depth 1 --branch "v${version}" https://github.com/aws/aws-emulator.git "${src}"
  git -C "${src}" apply "${here}/aws-emulator-run-memory.patch"
fi
commit="$(git -C "${src}" rev-parse HEAD)"

(
  cd "${src}"
  EMULATOR_VERSION="${version}" EMULATOR_RELEASE_DATE="${release_date}" EMULATOR_COMMIT="${commit}" \
    cargo build --release --locked -p aws-emulator-router
)

"${src}/target/release/aws-emulator" --version | grep -q "Version: ${version}"

stage="${work}/aws-emulator-${version}"
rm -rf "${stage}" && mkdir -p "${stage}"
cp "${src}/target/release/aws-emulator" "${src}/LICENSE" "${stage}/"
cp "${here}/aws-emulator-run-memory.patch" "${stage}/"
# Same commit as the upstream Linux package, so reuse its third-party notices.
deb="${work}/aws-emulator_${version}-1_arm64.deb"
curl -fsSL -o "${deb}" "https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/aws-emulator_${version}-1_arm64.deb"
(cd "${work}" && ar x "${deb}" data.tar.xz && tar -xOf data.tar.xz ./opt/aws-emulator/THIRD_PARTY_LICENSES >"${stage}/THIRD_PARTY_LICENSES" && rm data.tar.xz "${deb}")
archive="${work}/aws-emulator-${version}-macos-arm64.tar.gz"
COPYFILE_DISABLE=1 tar --no-xattrs -C "${work}" -czf "${archive}" "aws-emulator-${version}"
shasum -a 256 "${archive}"
