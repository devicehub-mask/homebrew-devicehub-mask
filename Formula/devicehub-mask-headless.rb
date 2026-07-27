class DevicehubMaskHeadless < Formula
  desc "Headless iOS device control and browser service"
  homepage "https://github.com/boa-z/devicehub-mask"
  url "https://github.com/boa-z/devicehub-mask/releases/download/nightly/devicehub-mask-headless_0.1.0%2B110_macos-universal.tar.gz"
  sha256 "4b41541ea5692df423245c9ae9cebceb0aa618213529ffc8dccb5d27bf3880e0"
  license "MIT"

  depends_on macos: :ventura

  def install
    payload = Pathname.glob("devicehub-mask-headless_*").find(&:directory?) || Pathname.pwd
    libexec.install payload.children
    (var/"devicehub-mask").mkpath
    (bin/"devicehub-headless").write <<~SH
      #!/bin/bash
      exec "#{libexec}/devicehub-headless" \
        --data-dir "#{var}/devicehub-mask" \
        --frontend-dir "#{libexec}/dist" \
        --ffmpeg "#{libexec}/ffmpeg" \
        --netmuxd "#{libexec}/netmuxd" \
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
    assert_match "Usage: devicehub-headless", shell_output("#{bin}/devicehub-headless --help")
  end
end
