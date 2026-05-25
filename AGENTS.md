# MicBar — Agent ガイド

macOS メニューバー常駐アプリ。Default Input Device の一覧表示・切替（v0.1）+ 常駐基盤（v0.2）。Background App（Dock 非表示）。

## 正本ドキュメント

| 用途 | ファイル |
|------|----------|
| 要件（v0.2） | [requirements-v02.md](./requirements-v02.md) |
| 要件（v0.1） | [requirements-v01.md](./requirements-v01.md) |
| タスク・チェックボックス（v0.2） | [implementation-plan-v02.md](./implementation-plan-v02.md) |
| タスク・チェックボックス（v0.1） | [implementation-plan-v01.md](./implementation-plan-v01.md) |
| フェーズ別サブエージェント手順（v0.2） | [docs/agent-implementation-plan-v02.md](./docs/agent-implementation-plan-v02.md) |
| 用語 | [CONTEXT.md](./CONTEXT.md) |
| ADR | [docs/adr/](./docs/adr/) |

## 技術スタック

- Swift / SwiftUI、`MenuBarExtra`、Core Audio（ネイティブ。配布物に CLI 依存なし）
- macOS 13+、arm64 のみ
- v0.2: `ServiceManagement` / `SMAppService`（Login Item）
- ビルド: Xcode（BOSS 実機 Build & Run）。CLI 検証は開発時のみ（[ADR-0001](./docs/adr/0001-core-audio-native-for-v01.md)）

## プロジェクト構成（目標）

`MicBar/` 配下: `UI/`, `State/`, `Domain/`, `Infrastructure/`, `Tests/` — 詳細は [implementation-plan-v01.md §0.4](./implementation-plan-v01.md)。

## 必須ワークフロー（すべての実装タスクで守る）

### 1. サブエージェントで効率的に実装する

[docs/agent-implementation-plan-v02.md](./docs/agent-implementation-plan-v02.md) のフェーズ表に従う。

| サブエージェント | 使う場面 |
|------------------|----------|
| `explore` | リポジトリ構造・既存パターンの調査 |
| `shell` | `xcodebuild`, `git`, Homebrew 検証コマンド |
| `generalPurpose` | 機能実装・スパイク・複数ファイルの変更 |
| `generalPurpose` + **`readonly: true`** | **フェーズ完了後のコードレビュー（必須）** |

- 前フェーズの完了条件を満たしてから次へ。

### 2. `implementation-plan-v02.md` のチェックを更新する

- タスクを完了したら、**同じセッション内で** [implementation-plan-v02.md](./implementation-plan-v02.md) の該当行を `- [ ]` → `- [x]` に更新する。
- フェーズの **完了条件** ブロックもすべて満たしたらチェックする。

### 3. `AGENTS.md` をこまめにコミットする

- 下記 **進捗ログ** に、フェーズ開始・完了・レビュー結果・ブロッカーを追記する。

### 4. 実装後は必ずサブエージェントでレビューする

- 各フェーズの実装が終わったら、`generalPurpose` + `readonly: true` でレビューを実行する。
- **Critical** がある間はフェーズ完了とみなさず、修正後に再レビューする。

## コマンド

```bash
xcodegen generate
xcodebuild -scheme MicBar -configuration Debug build
xcodebuild -scheme MicBar -configuration Debug test
```

## 実装時の注意（v0.2）

- 変更対象は **Default Input Device** のみ。Per-App Input Setting は触らない。
- Device Change Monitoring は Core Audio 通知のみ（常時ポーリング禁止、NF-002）。
- Background Refresh では `listState = .loading` にしない（[ADR-0003](./docs/adr/0003-device-change-monitoring-and-refresh-modes.md)）。
- Login Item 実状態は `SMAppService` が正。起動時・メニュー表示時にトグル同期。
- Menu Bar Label はデフォルトオフ。`UserDefaults` で `showMenuBarLabel` のみ永続化。
- v0.2 に含めない: 署名・DMG、グローバルショートカット、macOS 通知、Switch Error UI 改善。

## 進捗ログ

<!-- エージェントは作業のたびに上から追記（古いエントリは残す） -->

| 日付 | フェーズ | 内容 |
|------|----------|------|
| 2026-05-24 | — | AGENTS.md・agent-implementation-plan 作成。実装未着手（Phase 0）。 |
| 2026-05-24 | 0 | 開始。xcodegen + project.yml、骨格、LSUIElement、xcodebuild build 成功。 |
| 2026-05-24 | 0 | 完了。レビュー OK（自走確認: arm64 / macOS 13 / CoreAudio リンク）。 |
| 2026-05-24 | S | MicBarSpike で list/default/switch 実施。マイク権限ダイアログなし → **GO**。 |
| 2026-05-24 | S | 完了。switchaudio-osx は未導入のため CLI 比較は省略。 |
| 2026-05-24 | 1–5 | MenuBarExtra、Core Audio 一覧・切替、Store、UT 9 件緑を一括実装。 |
| 2026-05-24 | 1–5 | 完了。レビュー OK（Critical 0。Loading 文言のみ表示に修正済み）。 |
| 2026-05-24 | 6 | 実装・スパイクで Speaker Audio Recorder 等を確認。USB/AirPods/AC-006 は BOSS 手動 QA 待ち。 |
| 2026-05-24 | 6 | **完了**。BOSS 実機 QA OK — 一覧・切替・Dock 非表示を確認。v0.1 完了判定。 |
| 2026-05-25 | v0.2 | 開始。implementation-plan-v02、agent-implementation-plan-v02、ADR-0003 準拠の実装。 |
| 2026-05-25 | 1–3 | Monitoring + Settings + Menu Bar Label 実装。UT 拡張。 |
| 2026-05-25 | 4 | コード完了。BOSS 手動 QA（AC-009〜014）待ち。 |

**現在フェーズ**: v0.2 Phase 4（手動 QA）  
**次のアクション**: BOSS 実機で Login Item・抜き差し・Menu Bar Label・AC-014 を確認
