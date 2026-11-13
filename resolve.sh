#!/usr/bin/env bash
set -euo pipefail

base_url="https://www.ark-vcs.com"

page="$(curl -fsSL "$base_url/download.html")"

version="$(grep -m1 -oE '<div class="download-version">[0-9]+(\.[0-9]+)+' <<<"$page" | grep -oE '[0-9]+(\.[0-9]+)+$' || true)"
if [[ -z "$version" ]]; then
  echo "error: could not find version in $base_url/download.html" >&2
  exit 1
fi
echo "version=$version"

current="$(grep -hoE '^  version "[^"]+"' Formula/ark-vcs.rb Casks/ark-vcs.rb | cut -d'"' -f2 | sort -u)"
if [[ "$version" == "$current" ]]; then
  echo "homebrew=current"
  exit 0
fi

sha256_of() {
  curl -fsSL "$1" | shasum -a 256 | cut -d' ' -f1
}
file_version="${version//./_}"
mac_sha="$(sha256_of "$base_url/static/versions/Ark-Vcs_${file_version}_mac.zip")"
linux_sha="$(sha256_of "$base_url/static/versions/Ark-Vcs_${file_version}_linux.zip")"

echo "homebrew=outdated"
echo "mac_sha=$mac_sha"
echo "linux_sha=$linux_sha"
