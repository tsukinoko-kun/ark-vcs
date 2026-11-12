#!/usr/bin/env bash
set -euo pipefail

base_url="https://www.ark-vcs.com"
formula="Formula/ark-vcs.rb"
cask="Casks/ark-vcs.rb"

page="$(curl -fsSL "$base_url/download.html")"

version="$(grep -m1 -oE '<div class="download-version">[0-9]+(\.[0-9]+)+' <<<"$page" | grep -oE '[0-9]+(\.[0-9]+)+$' || true)"
if [[ -z "$version" ]]; then
  echo "error: could not find version in $base_url/download.html" >&2
  exit 1
fi

current="$(grep -hoE '^  version "[^"]+"' "$formula" "$cask" | cut -d'"' -f2 | sort -u)"
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
  url "$linux_url"
  version "$version"
  sha256 "$linux_sha"
  license :cannot_represent

  depends_on arch: :x86_64
  depends_on :linux

  def install
    bin.install "ark", "ark-cli"
  end
end
EOF

cat >"$cask" <<EOF
cask "ark-vcs" do
  version "$version"
  sha256 "$mac_sha"

  url "$base_url/static/versions/Ark-Vcs_#{version.dots_to_underscores}_mac.zip"
  name "Ark VCS"
  desc "Centralized version control system focused on game development"
  homepage "$base_url"

  app "Ark-Vcs_#{version.dots_to_underscores}/Ark-Vcs.app"
  binary "#{appdir}/Ark-Vcs.app/Contents/MacOS/ark"

  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{appdir}/Ark-Vcs.app"]
  end
end
EOF

echo "ark-vcs updated to $version"
