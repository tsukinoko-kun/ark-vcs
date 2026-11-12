cask "ark-vcs" do
  version "1.1.3"
  sha256 "f7734ece6d3e829d6c878db06cad40ba67a56b1ce3191d84547545053ce0f084"

  url "https://www.ark-vcs.com/static/versions/Ark-Vcs_#{version.dots_to_underscores}_mac.zip"
  name "Ark VCS"
  desc "Centralized version control system focused on game development"
  homepage "https://www.ark-vcs.com"

  app "Ark-Vcs_#{version.dots_to_underscores}/Ark-Vcs.app"
  binary "#{appdir}/Ark-Vcs.app/Contents/MacOS/ark"

  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{appdir}/Ark-Vcs.app"]
  end
end
