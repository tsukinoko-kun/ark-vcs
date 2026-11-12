#!/usr/bin/env bash
set -euo pipefail

base_url="https://www.ark-vcs.com"
formula="Formula/ark-vcs.rb"

page="$(curl -fsSL "$base_url/download.html")"

version="$(grep -m1 -oE '<div class="download-version">[0-9]+(\.[0-9]+)+' <<<"$page" | grep -oE '[0-9]+(\.[0-9]+)+$' || true)"
if [[ -z "$version" ]]; then
  echo "error: could not find version in $base_url/download.html" >&2
  exit 1
fi

current="$(grep -oE '^  version "[^"]+"' "$formula" | cut -d'"' -f2)"
if [[ "$version" == "$current" ]]; then
  echo "ark-vcs $version is up to date"
  exit 0
fi

file_version="${version//./_}"
mac_url="$base_url/static/versions/Ark-Vcs_${file_version}_mac.zip"
linux_url="$base_url/static/versions/Ark-Vcs_${file_version}_linux.zip"

sha256_of() {
  curl -fsSL "$1" | shasum -a 256 | cut -d' ' -f1
}
mac_sha="$(sha256_of "$mac_url")"
linux_sha="$(sha256_of "$linux_url")"

cat >"$formula" <<EOF
class ArkVcs < Formula
  desc "Centralized version control system focused on game development"
  homepage "$base_url"
  version "$version"
  license :cannot_represent

  on_macos do
    url "$mac_url"
    sha256 "$mac_sha"
  end

  on_linux do
    depends_on arch: :x86_64

    url "$linux_url"
    sha256 "$linux_sha"
  end

  def install
    bin.install "ark"
    bin.install "ark-cli" if OS.linux?
  end
end
EOF

echo "ark-vcs updated: $current -> $version"
