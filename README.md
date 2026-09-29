# SoundLamp

[English](README.en.md) | 日本語

Macの音量が0かどうかを、メニューバーのアイコンで確認するアプリです。

| 状態 | アイコン |
| --- | --- |
| 無音（音量0・ミュート） | <img src="docs/screenshots/menubar-silent.png" height="24" alt="無音"> 通常のアイコン |
| 音が出る | <img src="docs/screenshots/menubar-audible.png" height="24" alt="音が出る"> 青いアイコン |
| イヤホン・ヘッドホン | ヘッドホンのアイコン（音が出るときは中央に波形） |

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
