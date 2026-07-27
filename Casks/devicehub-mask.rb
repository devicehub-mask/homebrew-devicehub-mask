cask "devicehub-mask" do
  version "0.1.0,108"
  sha256 "12d28f85e1c3e948e181b43b455fe55450a59d8408725a6d15bee27f91eed88a"

  url "https://github.com/boa-z/devicehub-mask/releases/download/nightly/devicehub-mask_#{version.csv.first}%2B#{version.csv.second}_universal.dmg"
  name "DeviceHub Mask"
  desc "Control iOS devices with screen mirroring, touch input, and diagnostics"
  homepage "https://github.com/boa-z/devicehub-mask"

  depends_on macos: :ventura

  app "DeviceHub Mask.app"

  caveats <<~EOS
    Current builds use an ad-hoc signature because the project does not yet
    have an Apple Developer ID. If Gatekeeper blocks this trusted download,
    Control-click the app and choose Open, or run:

      sudo xattr -rd com.apple.quarantine "/Applications/DeviceHub Mask.app"
  EOS
end
