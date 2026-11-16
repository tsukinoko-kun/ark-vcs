#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <version> <mac_sha256> <linux_sha256>" >&2
  exit 1
fi
version="$1"
mac_sha="$2"
linux_sha="$3"

base_url="https://www.ark-vcs.com"
formula="Formula/ark-vcs.rb"
server_formula="Formula/ark-vcs-server.rb"
cask="Casks/ark-vcs.rb"
linux_url="$base_url/static/versions/Ark-Vcs_${version//./_}_linux.zip"
mac_url="$base_url/static/versions/Ark-Vcs_${version//./_}_mac.zip"

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

cat >"$server_formula" <<EOF
class ArkVcsServer < Formula
  desc "Server for Ark VCS, run as a background service"
  homepage "$base_url"
  url "$mac_url"
  version "$version"
  sha256 "$mac_sha"
  license :cannot_represent

  depends_on :macos

  def install
    libexec.install "ark"
    (bin/"ark-server").write <<~SH
      #!/bin/sh
      "#{opt_libexec}/ark" server -path "#{var}/ark" "\$@" &
      pid=\$!
      trap '' INT
      trap 'kill -INT "\$pid"; wait "\$pid"; exit \$?' TERM
      wait "\$pid"
    SH
    (bin/"ark-server").chmod 0755
  end

  post_install_steps do
    mkdir_p "ark", base: :var
  end

  def caveats
    <<~EOS
      Start the server at boot as your user:
        sudo brew services start --sudo-service-user "\$USER" ark-vcs-server

      brew upgrade does not restart the server. After every upgrade, run:
        sudo brew services restart --sudo-service-user "\$USER" ark-vcs-server

      Data: #{var}/ark
      Log:  #{var}/log/ark-server.log
    EOS
  end

  service do
    run opt_bin/"ark-server"
    keep_alive true
    require_root true
    log_path var/"log/ark-server.log"
    error_log_path var/"log/ark-server.log"
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
