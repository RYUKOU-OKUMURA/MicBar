# MicBar — Agent ガイド

macOS メニューバー常駐アプリ。Default Input Device の一覧表示・切替のみ（v0.1）。Background App（Dock 非表示）。

## 正本ドキュメント

| 用途 | ファイル |
|------|----------|
| 要件 | [requirements-v01.md](./requirements-v01.md) |
| タスク・チェックボックス | [implementation-plan-v01.md](./implementation-plan-v01.md) |
| フェーズ別サブエージェント手順 | [docs/agent-implementation-plan.md](./docs/agent-implementation-plan.md) |
| 用語 | [CONTEXT.md](./CONTEXT.md) |
| ADR | [docs/adr/](./docs/adr/) |

## 技術スタック

- Swift / SwiftUI、`MenuBarExtra`、Core Audio（ネイティブ。配布物に CLI 依存なし）
- macOS 13+、arm64 のみ
- ビルド: Xcode（BOSS 実機 Build & Run）。CLI 検証は開発時のみ（[ADR-0001](./docs/adr/0001-core-audio-native-for-v01.md)）

## プロジェクト構成（目標）

`MicBar/` 配下: `UI/`, `State/`, `Domain/`, `Infrastructure/`, `Tests/` — 詳細は [implementation-plan-v01.md §0.4](./implementation-plan-v01.md)。

## 必須ワークフロー（すべての実装タスクで守る）

### 1. サブエージェントで効率的に実装する

[docs/agent-implementation-plan.md](./docs/agent-implementation-plan.md) のフェーズ表に従う。

| サブエージェント | 使う場面 |
|------------------|----------|
| `explore` | リポジトリ構造・既存パターンの調査 |
| `shell` | `xcodebuild`, `git`, Homebrew 検証コマンド |
| `generalPurpose` | 機能実装・スパイク・複数ファイルの変更 |
| `generalPurpose` + **`readonly: true`** | **フェーズ完了後のコードレビュー（必須）** |

- Phase **S**（スパイク）完了・GO 判定まで **Phase 1 に入らない**（[ADR-0002](./docs/adr/0002-spikes-before-phase-1.md)）。
- 前フェーズの完了条件を満たしてから次へ。

### 2. `implementation-plan-v01.md` のチェックを更新する

- タスクを完了したら、**同じセッション内で** [implementation-plan-v01.md](./implementation-plan-v01.md) の該当行を `- [ ]` → `- [x]` に更新する。
- フェーズの **完了条件** ブロックもすべて満たしたらチェックする。
- スパイク結果は同ファイル末尾の **スパイク記録** 表に記入する。

### 3. `AGENTS.md` をこまめにコミットする

- 下記 **進捗ログ** に、フェーズ開始・完了・レビュー結果・ブロッカーを追記する。
- **追記のたびに**（少なくともフェーズ開始時・実装コミット後・フェーズ完了時）git commit する。メッセージ例: `docs(agents): Phase 2 開始` / `docs(agents): Phase 2 完了、レビュー OK`。
- 実装コードと AGENTS.md の更新を同一コミットにまとめてもよいが、**進捗ログの記録を省略しない**。

### 4. 実装後は必ずサブエージェントでレビューする

- 各フェーズの実装が終わったら、`generalPurpose` + `readonly: true` でレビューを実行する。
- 依頼文は [docs/agent-implementation-plan.md § レビュー依頼テンプレート](./docs/agent-implementation-plan.md) を使う。
- **Critical** がある間はフェーズ完了とみなさず、修正後に再レビューする。
- 結果サマリ（OK / 指摘件数）を進捗ログに 1〜3 行で残す。

## コマンド（Xcode プロジェクト作成後）

```bash
# ビルド（プロジェクト名・スキームは作成後に要確認）
xcodebuild -scheme MicBar -configuration Debug build

# テスト
xcodebuild -scheme MicBar -configuration Debug test
```

プロジェクト未作成時は Phase 0 を先に完了する。

## 実装時の注意

- 変更対象は **Default Input Device** のみ。Per-App Input Setting は触らない・v0.1 で説明 UI なし。
- 切替成功: 通知・トーストなし（Switch Success）。失敗: メニュー内の Switch Error 定型文のみ。
- Device List Loading 中は「入力デバイスを取得中…」のみ（stale list 禁止）。
- Core Audio 呼び出しは `CoreAudioService` に集約。UI から直接呼ばない。
- v0.1 に含めない: ログイン時起動、自動監視、グローバルショートカット、通知、Menu Bar 常時ラベル。

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

**現在フェーズ**: Phase 6（手動 QA — BOSS 最終確認残）  
**次のアクション**: BOSS 実機で §6.1 USB/AirPods・AC-006・Dock 非表示を確認 → v0.1 完了判定
