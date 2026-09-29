# SoundLamp

English | [日本語](README.md)

A menu bar app that shows whether your Mac's volume is at 0.

| State | Icon |
| --- | --- |
| Silent (volume 0 or muted) | Regular icon |
| Sound on | Blue icon |
| Headphones | Headphone icon (with a waveform when sound is on) |

The menu shows the volume and output device, plus "Set Volume to 0" and "Launch at Login".

Requires macOS 13 or later.

<!-- Screenshots will go in docs/screenshots/
![SoundLamp](docs/screenshots/menu.png)
-->

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
