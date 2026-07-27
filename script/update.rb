#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open-uri"
require "pathname"

REPOSITORY = "boa-z/devicehub-mask"
TAG = ARGV.fetch(0, "nightly")
ROOT = Pathname.new(__dir__).parent
USER_AGENT = "devicehub-mask-homebrew-tap"

def read_url(url)
  URI.open(url, "User-Agent" => USER_AGENT, &:read)
end

release = JSON.parse(read_url("https://api.github.com/repos/#{REPOSITORY}/releases/tags/#{TAG}"))
assets = release.fetch("assets").to_h { |asset| [asset.fetch("name"), asset] }
headless_assets = assets.keys.grep(/\Adevicehub-mask-headless_(\d+\.\d+\.\d+)\+(\d+)_macos-universal\.tar\.gz\z/)
abort "release #{TAG} must contain exactly one macOS headless archive" unless headless_assets.length == 1
headless = headless_assets.first
match = headless.match(/\Adevicehub-mask-headless_(\d+\.\d+\.\d+)\+(\d+)_macos-universal\.tar\.gz\z/)
app_version = match[1]
build = match[2]
dmg = "devicehub-mask_#{app_version}+#{build}_universal.dmg"

[headless, "#{headless}.sha256", dmg, "#{dmg}.sha256"].each do |name|
  abort "release #{TAG} is missing #{name}" unless assets.key?(name)
end

checksum = lambda do |name|
  content = read_url(assets.fetch("#{name}.sha256").fetch("browser_download_url"))
  digest = content.split.first
  abort "invalid checksum for #{name}" unless digest&.match?(/\A[0-9a-f]{64}\z/)
  digest
end

formula = <<~RUBY
  class DevicehubMaskHeadless < Formula
    desc "Headless iOS device control and browser service"
    homepage "https://github.com/boa-z/devicehub-mask"
    url "#{assets.fetch(headless).fetch("browser_download_url")}"
    sha256 "#{checksum.call(headless)}"
    license "MIT"

    depends_on macos: :ventura

    def install
      payload = Pathname.glob("devicehub-mask-headless_*").find(&:directory?) || Pathname.pwd
      libexec.install payload.children
      (var/"devicehub-mask").mkpath
      (bin/"devicehub-headless").write <<~SH
        #!/bin/bash
        exec "\#{libexec}/devicehub-headless" \\
          --data-dir "\#{var}/devicehub-mask" \\
          --frontend-dir "\#{libexec}/dist" \\
          --ffmpeg "\#{libexec}/ffmpeg" \\
          --netmuxd "\#{libexec}/netmuxd" \\
          "$@"
      SH
    end

    def caveats
      <<~EOS
        Start the service in the foreground with:
          devicehub-headless

        Use --allow-lan together with a non-loopback --listen address only on a
        trusted network. The startup URL contains an access token.
      EOS
    end

    test do
      assert_match "Usage: devicehub-headless", shell_output("\#{bin}/devicehub-headless --help")
    end
  end
RUBY

cask = <<~RUBY
  cask "devicehub-mask" do
    version "#{app_version},#{build}"
    sha256 "#{checksum.call(dmg)}"

    url "#{assets.fetch(dmg).fetch("browser_download_url")}"
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
RUBY

(ROOT/"Formula").mkpath
(ROOT/"Casks").mkpath
(ROOT/"Formula/devicehub-mask-headless.rb").write(formula)
(ROOT/"Casks/devicehub-mask.rb").write(cask)
warn "updated Formula and Cask from #{TAG} (#{app_version}+#{build})"
