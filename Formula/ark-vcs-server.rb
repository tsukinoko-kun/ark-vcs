class ArkVcsServer < Formula
  desc "Server for Ark VCS, run as a background service"
  homepage "https://www.ark-vcs.com"
  url "https://www.ark-vcs.com/static/versions/Ark-Vcs_1_1_3_mac.zip"
  version "1.1.3"
  sha256 "f7734ece6d3e829d6c878db06cad40ba67a56b1ce3191d84547545053ce0f084"
  license :cannot_represent

  depends_on :macos

  def install
    libexec.install "ark"
    (bin/"ark-server").write <<~SH
      #!/bin/sh
      "#{opt_libexec}/ark" server -path "#{var}/ark" "$@" &
      pid=$!
      trap '' INT
      trap 'kill -INT "$pid"; wait "$pid"; exit $?' TERM
      wait "$pid"
    SH
    (bin/"ark-server").chmod 0755
  end

  post_install_steps do
    mkdir_p "ark", base: :var
  end

  def caveats
    <<~EOS
      Start the server at boot as your user:
        sudo brew services start --sudo-service-user "$USER" ark-vcs-server

      brew upgrade does not restart the server. After every upgrade, run:
        sudo brew services restart --sudo-service-user "$USER" ark-vcs-server

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
