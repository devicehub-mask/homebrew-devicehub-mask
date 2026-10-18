# Homebrew Tap for DeviceHub Mask

This tap distributes the macOS desktop application and the headless browser service from [DeviceHub Mask releases](https://github.com/devicehub-mask/devicehub-mask/releases).

## Desktop application

```sh
brew tap devicehub-mask/devicehub-mask
brew install --cask devicehub-mask
```

## Headless service

```sh
brew tap devicehub-mask/devicehub-mask
brew install devicehub-mask-headless
devicehub-headless --help
```

The `devicehub-mask-headless` Formula installs the complete headless bundle, including the browser UI, FFmpeg, netmuxd, and license files. It stores runtime data under Homebrew's `var/devicehub-mask` directory by default. The Formula is published only when a matching macOS headless archive and checksum are present in the upstream release.

## Updating the tap

The upstream release workflow sends a `devicehub-release` repository dispatch after publishing complete artifacts. Maintainers can also run the **Update Formula and Cask** workflow manually with a release tag such as `nightly` or `v0.1.0`.

## License

The tap metadata is available under the MIT License. DeviceHub Mask and bundled third-party components retain their own licenses.
