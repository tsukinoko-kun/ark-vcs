class ArkVcs < Formula
  desc "Centralized version control system focused on game development"
  homepage "https://www.ark-vcs.com"
  url "https://www.ark-vcs.com/static/versions/Ark-Vcs_1_1_3_linux.zip"
  version "1.1.3"
  sha256 "ddf384019600fc132623afd06c8418757e37891b0a6274bc136130f55ae8edca"
  license :cannot_represent

  depends_on arch: :x86_64
  depends_on :linux

  def install
    bin.install "ark", "ark-cli"
  end
end
