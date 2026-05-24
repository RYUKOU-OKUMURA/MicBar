# MicBar

macOS メニューバーから Default Input Device（デフォルト入力デバイス）を切り替える Background App（v0.1）。

## 要件・計画

- [requirements-v01.md](./requirements-v01.md)
- [implementation-plan-v01.md](./implementation-plan-v01.md)
- [AGENTS.md](./AGENTS.md)

## ビルド

MicBar は **Debug ビルドの出力先が `/Applications/MicBar.app` 固定** です。DerivedData に2つ目の `.app` ができないため、Launchpad に重複しません。

```bash
brew install xcodegen   # 初回のみ
xcodegen generate
xcodebuild -scheme MicBar -configuration Debug build
open -a /Applications/MicBar.app
```

**初回セットアップ / 重複が残ったとき**（DerivedData 旧コピーの削除 + Launchpad キャッシュリセット）:

```bash
./scripts/install-micbar.sh
```

## テスト

```bash
xcodebuild -scheme MicBar -configuration Debug test
```

**UT スコープ**: `DisplayNameFormatter` と `AudioDeviceStore`（モック注入）のみ。UI と実機 Core Audio は手動 QA（Phase 6）。

## スパイク（開発用）

```bash
xcodebuild -scheme MicBarSpike -configuration Debug build
.build/.../MicBarSpike list
.build/.../MicBarSpike default
.build/.../MicBarSpike switch "Device Name"
```

## 構成

```text
MicBar/           アプリ本体
MicBarSpike/      Phase S 用 Core Audio 検証 CLI
MicBarTests/      ユニットテスト
project.yml       XcodeGen 定義
```
