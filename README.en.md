# SoundLamp

English | [日本語](README.md)

A menu bar app that shows whether your Mac's volume is at 0.

| State | Icon |
| --- | --- |
| Silent (volume 0 or muted) | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/icon-silent-dark.svg"><img src="docs/images/icon-silent-light.svg" width="40" alt="Silent"></picture> |
| Sound on | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/icon-audible-dark.svg"><img src="docs/images/icon-audible-light.svg" width="40" alt="Sound on"></picture> |
| Headphones | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/icon-headphones-dark.svg"><img src="docs/images/icon-headphones-light.svg" width="40" alt="Headphones"></picture><br>Waveform in the center when sound is on |

The menu shows the volume and output device, plus "Set Volume to 0" and "Launch at Login".

Requires macOS 13 or later.

## Install

Download the dmg from [Releases](https://github.com/oyuaki/SoundLamp/releases) and move `SoundLamp.app` to Applications.

The app is not signed, so macOS blocks it the first time. Click "Open Anyway" in System Settings → Privacy & Security, or run:

```sh
xattr -dr com.apple.quarantine /Applications/SoundLamp.app
```

## Build

Requires Xcode 16 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
open SoundLamp.xcodeproj
```

- Tests: `swift test`
- Release dmg/zip: `scripts/package.sh 1.0.0`

## License

[MIT](LICENSE)
