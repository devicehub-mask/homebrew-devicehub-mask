cask "devicehub-mask" do
  version "0.1.0,110"
  sha256 "34242b74381eb693f4e27ce915a21abf73afa16ff412a4e922c940267efea93e"

  url "https://github.com/boa-z/devicehub-mask/releases/download/nightly/devicehub-mask_#{version.csv.first}%2B#{version.csv.second}_universal.dmg"
  name "DeviceHub Mask"
  desc "Control iOS devices with screen mirroring, touch input, and diagnostics"
  homepage "https://github.com/boa-z/devicehub-mask"

  depends_on macos: :ventura

  app "DeviceHub Mask.app"

  caveats <<~EOS
    Current builds use an ad-hoc signature. If Gatekeeper blocks this trusted
    download, Control-click the app and choose Open, or run:

      sudo xattr -rd com.apple.quarantine "/Applications/DeviceHub Mask.app"
  EOS
end
