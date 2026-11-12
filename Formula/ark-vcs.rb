class ArkVcs < Formula
  desc "Centralized version control system focused on game development"
  homepage "https://www.ark-vcs.com"
  version "1.1.3"
  license :cannot_represent

  on_macos do
    url "https://www.ark-vcs.com/static/versions/Ark-Vcs_1_1_3_mac.zip"
    sha256 "f7734ece6d3e829d6c878db06cad40ba67a56b1ce3191d84547545053ce0f084"
  end

  on_linux do
    depends_on arch: :x86_64

    url "https://www.ark-vcs.com/static/versions/Ark-Vcs_1_1_3_linux.zip"
    sha256 "ddf384019600fc132623afd06c8418757e37891b0a6274bc136130f55ae8edca"
  end

  def install
    bin.install "ark"
    bin.install "ark-cli" if OS.linux?
  end
end
