# DESIGN_TODO

SoundLamp に必要な画像の一覧です。ファイルを所定の場所に置くだけで反映されます（`Contents.json` は作成済みなので編集不要）。
画像が無い間は、メニューバーは SF Symbols（`speaker.slash.fill` / 青の `speaker.wave.2.fill` / ヘッドホン時は `headphones`）で表示されます。

共通仕様：PNG、sRGB、透過あり。ファイル名は下記のとおり正確に（大文字小文字も一致させる）。

## 進捗

- [x] メニューバーアイコン（無音／音あり）
- [x] アプリアイコン（全サイズ）
- [ ] README 用スクリーンショット

## 1. メニューバーアイコン

コンセプト：色と形が「静かに」変わるだけのランプ。無音と音ありは色が無くても形で区別できること。

| 状態 | 置き場所 | ファイル名 | サイズ (px) |
| --- | --- | --- | --- |
| 無音 | `App/Assets.xcassets/MenuIconSilent.imageset/` | `MenuIconSilent.png` | 18 × 18 |
| 無音 | 同上 | `MenuIconSilent@2x.png` | 36 × 36 |
| 音あり | `App/Assets.xcassets/MenuIconAudible.imageset/` | `MenuIconAudible.png` | 18 × 18 |
| 音あり | 同上 | `MenuIconAudible@2x.png` | 36 × 36 |
| ヘッドホン・無音 | `App/Assets.xcassets/MenuIconHeadphonesSilent.imageset/` | `MenuIconHeadphonesSilent.png` | 18 × 18 |
| ヘッドホン・無音 | 同上 | `MenuIconHeadphonesSilent@2x.png` | 36 × 36 |
| ヘッドホン・音あり | `App/Assets.xcassets/MenuIconHeadphonesAudible.imageset/` | `MenuIconHeadphonesAudible.png` | 18 × 18 |
| ヘッドホン・音あり | 同上 | `MenuIconHeadphonesAudible@2x.png` | 36 × 36 |

### MenuIconSilent（無音）
- **テンプレート画像**：黒（#000000）＋ アルファのみで描く。色は使わない
  - macOS が自動でダークモードでは白、ライトモードでは黒に塗り替える（`template-rendering-intent: template` 設定済み）
- 横幅は 18pt 以内（横長にしたい場合は幅を広げても可。高さは 18pt を超えない）
- 上下に 1〜2pt 程度の余白を持たせると他のメニューバーアイコンと揃う

### MenuIconAudible（音あり）
- **カラー画像**（`template-rendering-intent: original` 設定済み。色はそのまま表示される）
- メインカラーは青。目安は macOS の systemBlue（ライト `#007AFF` / ダーク `#0A84FF`）
- 1枚でライト/ダーク両方のメニューバーで視認できること（白・黒どちらの背景でも沈まない青）
- 無音アイコンとは**形も変える**（色覚に頼らず区別できるように）
- サイズ・余白は無音アイコンと揃える

### MenuIconHeadphonesSilent / MenuIconHeadphonesAudible（イヤホン・ヘッドホン接続中）
- どちらも**テンプレート画像**（黒＋アルファのみ。`template-rendering-intent: template` 設定済み）
- 音ありは中央に波形を入れ、無音は波形なし。色ではなく形で区別する

## 2. アプリアイコン

置き場所：`App/Assets.xcassets/AppIcon.appiconset/`

| ファイル名 | サイズ (px) |
| --- | --- |
| `icon_16x16.png` | 16 × 16 |
| `icon_16x16@2x.png` | 32 × 32 |
| `icon_32x32.png` | 32 × 32 |
| `icon_32x32@2x.png` | 64 × 64 |
| `icon_128x128.png` | 128 × 128 |
| `icon_128x128@2x.png` | 256 × 256 |
| `icon_256x256.png` | 256 × 256 |
| `icon_256x256@2x.png` | 512 × 512 |
| `icon_512x512.png` | 512 × 512 |
| `icon_512x512@2x.png` | 1024 × 1024 |

- macOS（Big Sur 以降）スタイルの角丸スクエア
- 1024 × 1024 のキャンバスに対し、本体は約 824 × 824 を中央に配置（周囲は透過の余白、影は本体の内側に収める）
- 角丸は本体サイズの約 22.5%（824px なら半径 約185px）
- 小さいサイズ（16, 32）は縮小だけでなく、線を太くする等の調整を推奨

## 3. README 用スクリーンショット

置き場所：`docs/screenshots/`（配置後、`README.md` と `README.en.md` のスクリーンショット欄のコメントを外す）

| ファイル名 | 内容 | 推奨サイズ |
| --- | --- | --- |
| `menubar-silent.png` | 無音時のメニューバー付近の切り抜き | 横 600px 前後（Retina 撮影のまま可） |
| `menubar-audible.png` | 音あり時のメニューバー付近の切り抜き | 同上 |
| `menu.png` | メニューを開いた状態 | 横 600〜800px |

- ライト/ダーク両方を見せたい場合は `-light` / `-dark` を付けて追加（例：`menubar-silent-dark.png`）。README 側も合わせて更新する
- 個人情報（他のメニューバー項目、デバイス名など）が写り込まないよう注意
