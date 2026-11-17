#!/usr/bin/env bash
# Releases a new aws-emulator version in this tap, in one command:
#   1. builds the macOS arm64 archive (build-aws-emulator.sh),
#   2. creates the GitHub release aws-emulator-<version> with that archive,
#   3. updates Formula/aws-emulator.rb (version, URLs, all three SHA-256 values),
#   4. pushes a branch and opens a PR, so CI tests Linux and macOS before merge.
#
# Usage: macos/release-aws-emulator.sh [version] [work-dir]
#   version: for example 1.0.481. Default: the newest LTS version upstream.
# Needs: gh (signed in), git, curl, plus what build-aws-emulator.sh needs.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "${here}/.." && pwd)"
formula="${repo}/Formula/aws-emulator.rb"
packages="https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS"

version="${1:-}"
if [[ -z "${version}" ]]
then
  # versions.json lists "<x.y.z>.<package release>", for example 1.0.481.1.
  versions_json="$(curl -fsSL "${packages}/versions.json")"
  version="$(python3 -I -c 'import json, sys; print(json.loads(sys.argv[1])["versions"][-1]["version"].rsplit(".", 1)[0])' "${versions_json}")"
fi
work="${2:-${TMPDIR:-/tmp}/aws-emulator-build}"

current="$(sed -n 's/^  version "\(.*\)"$/\1/p' "${formula}")"
if [[ "${version}" == "${current}" ]]
then
  echo "The formula already has aws-emulator ${version}." >&2
  exit 1
fi

dirty="$(git -C "${repo}" status --porcelain)"
if [[ -n "${dirty}" ]]
then
  echo "Commit or stash your changes in ${repo} first." >&2
  exit 1
fi

# The upstream release date, as `aws-emulator --version` shows it (YYYY.MM.DD).
published="$(gh api "repos/aws/aws-emulator/releases/tags/v${version}" --jq .published_at)"
release_date="$(echo "${published}" | cut -c1-10 | tr - .)"

echo "==> Building aws-emulator ${version} (upstream release date ${release_date})"
build_output="$("${here}/build-aws-emulator.sh" "${version}" "${release_date}" "${work}")"
macos_sha="$(echo "${build_output}" | tail -1 | cut -d' ' -f1)"
archive="${work}/aws-emulator-${version}-macos-arm64.tar.gz"

sha_of_url() {
  local sum
  sum="$(curl -fsSL "$1" | shasum -a 256)"
  echo "${sum%% *}"
}
echo "==> Getting the Linux package checksums"
amd64_sha="$(sha_of_url "${packages}/aws-emulator_${version}-1_amd64.deb")"
arm64_sha="$(sha_of_url "${packages}/aws-emulator_${version}-1_arm64.deb")"

tag="aws-emulator-${version}"
commit="$(git -C "${work}/src-${version}" rev-parse HEAD)"
echo "==> Creating the GitHub release ${tag}"
gh release create "${tag}" "${archive}" --repo jeffabailey/homebrew-tap \
  --title "aws-emulator ${version} (macOS arm64)" \
  --notes "Unofficial macOS arm64 build of [aws-emulator](https://github.com/aws/aws-emulator) v${version} (commit ${commit}), built with \`macos/build-aws-emulator.sh\` and \`macos/aws-emulator-run-memory.patch\`. On macOS, Lambda memory use is not measured, so REPORT lines show 1 MB and function memory limits are not enforced."
asset_url="https://github.com/jeffabailey/homebrew-tap/releases/download/${tag}/aws-emulator-${version}-macos-arm64.tar.gz"
uploaded_sha="$(sha_of_url "${asset_url}")"
if [[ "${uploaded_sha}" != "${macos_sha}" ]]
then
  echo "The uploaded archive has SHA-256 ${uploaded_sha}, not ${macos_sha}." >&2
  exit 1
fi

echo "==> Updating ${formula}"
branch="aws-emulator-${version}"
git -C "${repo}" switch --quiet --create "${branch}"
python3 -I "${here}/update-formula.py" "${formula}" "${current}" "${version}" \
  "${amd64_sha}" "${arm64_sha}" "${macos_sha}"

git -C "${repo}" commit --quiet --all --message "aws-emulator ${version}"
git -C "${repo}" push --quiet --set-upstream origin "${branch}"
gh pr create --repo jeffabailey/homebrew-tap --head "${branch}" --base main \
  --title "aws-emulator ${version}" \
  --body "Update aws-emulator to upstream v${version}. The macOS arm64 archive is in release ${tag}."
git -C "${repo}" switch --quiet main
