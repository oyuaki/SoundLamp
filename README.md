# SoundLamp

[English](README.en.md) | 日本語

Macの音量が「ちゃんと0か」を、メニューバーのアイコンでひと目で確認するためのアプリです。

- **無音**（音量0 またはミュート）→ 通常のアイコン（ダークモードで白、ライトモードで黒）
- **音が出る状態** → 青いアイコン（形も変わります）

色と形が静かに切り替わるだけです。点滅・アニメーション・通知・音・ポップアップは一切ありません。

## スクリーンショット

<!-- 画像は docs/screenshots/ に配置予定（DESIGN_TODO.md 参照）。配置後にコメントを外してください。
| 無音 | 音あり | メニュー |
| --- | --- | --- |
| ![無音](docs/screenshots/menubar-silent.png) | ![音あり](docs/screenshots/menubar-audible.png) | ![メニュー](docs/screenshots/menu.png) |
-->

_準備中_

## 特長

- デフォルト出力デバイスの音量とミュートを Core Audio のリスナーで監視（ポーリングなし）
- AirPods・イヤホン・外部ディスプレイなどへの出力切り替えにも追従
- 音量を取得できないデバイスは、ミュートでなければ「音あり」として扱います
- メニューから
  - 現在の状態（例：「無音（音量0）」「音が出ます（45%）」）と出力デバイス名
  - 音量を0にする（すでに0ならグレーアウト。音量を変えられないデバイスではミュートにします）
  - ログイン時に起動
- Dockに表示されません
- 日本語・英語対応
- macOS 13 Ventura 以降、Apple シリコン / Intel（Universal）

## インストール

1. [Releases](https://github.com/oyuaki/SoundLamp/releases) から最新の `SoundLamp-x.y.z.dmg`（または `.zip`）をダウンロード
2. `SoundLamp.app` を「アプリケーション」フォルダへドラッグ
3. 下記「未署名アプリの開き方」に従って起動

### 未署名アプリの開き方

SoundLamp は Apple の Developer ID で署名・公証されていない（アドホック署名の）ため、初回起動時に「開けません」と表示されます。以下のどちらかで開けます。

**方法A：システム設定から許可する**

1. `SoundLamp.app` をダブルクリック（警告が出たら「完了」で閉じる）
2. 「システム設定」→「プライバシーとセキュリティ」を開く
3. 下の方にある「"SoundLamp"は開けませんでした…」の横の **「このまま開く」** をクリック
4. 再度確認が出たら「このまま開く」を選び、パスワードを入力

**方法B：ターミナルで隔離属性を外す**

```sh
xattr -dr com.apple.quarantine /Applications/SoundLamp.app
```

## 使い方

起動するとメニューバーにアイコンが出ます。クリックすると状態と出力デバイス名が表示されます。
「ログイン時に起動」をオンにすると、Mac にログインしたときに自動で起動します（「アプリケーション」フォルダに置いた状態で設定してください）。

## ビルド方法

必要なもの：Xcode 16 以降、[XcodeGen](https://github.com/yonaskolb/XcodeGen)

```sh
brew install xcodegen
git clone https://github.com/oyuaki/SoundLamp.git
cd SoundLamp
xcodegen generate
open SoundLamp.xcodeproj
```

コマンドラインでビルド・テストする場合：

```sh
xcodegen generate
xcodebuild -project SoundLamp.xcodeproj -scheme SoundLamp -destination 'platform=macOS' test
```

配布用（Universal、アドホック署名、dmg/zip）を作る場合：

```sh
scripts/package.sh 1.0.0   # dist/ に出力
```

判定ロジック（`Sources/SoundLampCore`）は Xcode がなくても Swift Package としてテストできます：

```sh
swift test
```

### 構成

| パス | 内容 |
| --- | --- |
| `project.yml` | XcodeGen のプロジェクト定義 |
| `App/` | メニューバーアプリ（SwiftUI `MenuBarExtra`） |
| `Sources/SoundLampCore/` | Core Audio の監視と判定ロジック |
| `Tests/SoundLampCoreTests/` | ユニットテスト（デバイス切り替えを含む） |
| `App/Assets.xcassets/` | アプリアイコン・メニューバーアイコン（未配置なら SF Symbols を使用） |

## ライセンス

[MIT](LICENSE)
