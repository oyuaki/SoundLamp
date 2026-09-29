# SoundLamp

[English](README.en.md) | 日本語

Macの音量が0かどうかを、メニューバーのアイコンで確認するアプリです。

| 状態 | アイコン |
| --- | --- |
| 無音（音量0・ミュート） | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/icon-silent-dark.svg"><img src="docs/images/icon-silent-light.svg" width="40" alt="無音"></picture> |
| 音が出る | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/icon-audible-dark.svg"><img src="docs/images/icon-audible-light.svg" width="40" alt="音が出る"></picture> |
| イヤホン・ヘッドホン | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/icon-headphones-dark.svg"><img src="docs/images/icon-headphones-light.svg" width="40" alt="イヤホン・ヘッドホン"></picture><br>音が出るときは中央に波形 |

メニューには音量と出力デバイス名、「音量を0にする」「ログイン時に起動」があります。

macOS 13以降。

## インストール

[Releases](https://github.com/oyuaki/SoundLamp/releases) から dmg をダウンロードし、`SoundLamp.app` をアプリケーションフォルダに入れてください。

署名していないため、初回は開けません。「システム設定」→「プライバシーとセキュリティ」で「このまま開く」を押すか、次を実行してください。

```sh
xattr -dr com.apple.quarantine /Applications/SoundLamp.app
```

## ビルド

Xcode 16以降と [XcodeGen](https://github.com/yonaskolb/XcodeGen) が必要です。

```sh
brew install xcodegen
xcodegen generate
open SoundLamp.xcodeproj
```

- テスト：`swift test`
- 配布用の dmg/zip：`scripts/package.sh 1.0.0`

## ライセンス

[MIT](LICENSE)
