# MicBar v0.1 — エージェント実装計画

> **進捗チェックリスト（正本）**: [implementation-plan-v01.md](../implementation-plan-v01.md)  
> **エージェント運用ルール**: [AGENTS.md](../AGENTS.md)  
> **要件**: [requirements-v01.md](../requirements-v01.md)

本書は `implementation-plan-v01.md` を、Cursor サブエージェント前提で **いつ・何を・誰が** やるかに落とし込んだ実行計画である。タスクの完了定義とチェックボックスは実装計画ファイル側が正本。

---

## 原則

| ルール | 内容 |
|--------|------|
| フェーズゲート | 前フェーズの **完了条件** を満たすまで次フェーズに進まない |
| 進捗更新 | 完了したタスクは `implementation-plan-v01.md` で `- [x]` にする |
| AGENTS.md | フェーズ開始・完了・スパイク結果・既知問題を `AGENTS.md` の進捗ログに追記し、**こまめに git commit** する |
| レビュー | 各フェーズの実装コミット後、**必ずサブエージェントでレビュー**（下記テンプレート） |
| 用語 | UI は「入力デバイス」。「マイク」はユーザー向け文言に使わない（[CONTEXT.md](../CONTEXT.md)） |

---

## フェーズ別サブエージェント割当

```text
Phase 0 ──► Phase S (ADR-0002) ──► Phase 1 ──► 2 ──► 3 ──► 4 ──► 5 ──► 6
              ↑ GO/NO-GO 必須
```

### Phase 0: プロジェクト準備

| ステップ | 担当 | 作業 |
|----------|------|------|
| 0-a | `shell` | Xcode / CLT / arm64 環境確認 |
| 0-b | `generalPurpose` | Xcode プロジェクト作成、Background App 設定、フォルダ骨格 |
| 0-c | `shell` | `xcodebuild` でビルド成功確認 |
| レビュー | `generalPurpose` + `readonly: true` | ターゲット macOS 13 / arm64 / UIElement / ディレクトリ構成 |

**出口**: MenuBarExtra ダミーで起動・Dock 非表示。

---

### Phase S: 事前検証（Phase 1 の前に必須）

| ステップ | 担当 | 作業 |
|----------|------|------|
| S-a | `generalPurpose` | Core Audio 最小アプリ（一覧・現在・切替） |
| S-b | `shell` | （任意）`switchaudio-osx` で BOSS 実機比較 |
| S-c | 親エージェント | `implementation-plan-v01.md` 末尾 **スパイク記録** と `docs/adr/` 更新、GO/NO-GO 判定 |

**出口**: マイク権限方針確定、BOSS 環境で切替可能を確認（[ADR-0002](../docs/adr/0002-spikes-before-phase-1.md)）。

---

### Phase 1: メニューシェル

| ステップ | 担当 | 作業 |
|----------|------|------|
| 1-a | `generalPurpose` | `MenuBarExtra`、固定メニュー、終了 |
| 1-b | 手動（BOSS） | AC-001, AC-007 確認 |
| レビュー | `readonly` | Background App・終了動作・v0.1 メニューに余計な行がないか |

**出口**: AC-001, AC-007。

---

### Phase 2: Core Audio 一覧

| ステップ | 担当 | 作業 |
|----------|------|------|
| 2-a | `generalPurpose` | Domain（`AudioInputDevice`, `DisplayNameFormatter`, `AudioDeviceError`） |
| 2-b | `generalPurpose` | `CoreAudioService` 読み取り、`AudioDeviceStore`, UI 一覧・Loading・Tooltip |
| 2-c | `explore` | 既存 Swift 慣例・Core Audio 呼び出しパターンの横断確認（必要時） |
| レビュー | `readonly` | UI から Core Audio 直叩きがないか、§9.2/9.3 文言、Device List Loading |

**出口**: AC-002, AC-003, AC-008、システム設定「入力」と一致。

---

### Phase 3: 切り替え

| ステップ | 担当 | 作業 |
|----------|------|------|
| 3-a | `generalPurpose` | `setDefaultInputDevice`、`switchDevice`、メニューアクション |
| レビュー | `readonly` | Switch Success 無言、§9.4 文言、切替後 refresh |

**出口**: AC-004, AC-005。

---

### Phase 4: エラー耐性・仕上げ

| ステップ | 担当 | 作業 |
|----------|------|------|
| 4-a | `generalPurpose` | 切断デバイス・再入・文言最終確認 |
| レビュー | `readonly` | NF-004、競合時の Store 整合性 |

**出口**: AC-006、§9.1〜9.4 手動確認。

---

### Phase 5: ユニットテスト

| ステップ | 担当 | 作業 |
|----------|------|------|
| 5-a | `generalPurpose` | `DisplayNameFormatterTests`, モック付き `AudioDeviceStoreTests` |
| 5-b | `shell` | `xcodebuild test` 全緑 |
| レビュー | `readonly` | UI/Core Audio が UT に混ざっていないか |

**出口**: 計画 §5 の UT すべてパス。

---

### Phase 6: 手動 QA・v0.1 完了

| ステップ | 担当 | 作業 |
|----------|------|------|
| 6-a | 手動（BOSS） | §6.1〜6.3 デバイス・フロー・外部アプリ |
| 6-b | 親エージェント | AC-001〜008 チェック、`既知の問題` 更新 |
| レビュー | `readonly` | requirements スコープ外機能が入っていないか |

**出口**: 全 AC クリア、BOSS が v0.1 利用可と判断。

---

## フェーズ完了時のレビュー依頼テンプレート

サブエージェント（`generalPurpose`, `readonly: true`）に渡す:

```text
MicBar Phase {N} の実装をレビューしてください。

参照:
- requirements-v01.md（該当 F-xxx, AC-xxx）
- implementation-plan-v01.md Phase {N}
- CONTEXT.md（用語・UI文言）

確認観点:
1. 完了条件・受け入れ条件を満たしているか
2. v0.1 スコープ外（F-007, F-009, 通知, ポーリング等）が混入していないか
3. Core Audio が UI 層に漏れていないか
4. ユーザー向け文言が requirements と一致するか
5. テスト・ビルド上の明らかな欠陥

出力: Critical / Suggestion / OK の3段階で、ファイルパス付き。
```

Critical があれば修正 → 再レビュー。Suggestion は AGENTS.md 進捗ログに記録可。

---

## 並列化の目安

| 並列可 | 例 |
|--------|-----|
| ○ | Phase 2 の Domain と `explore`（既存コード調査） |
| ○ | Phase 5 の Formatter UT と Store モック設計（ファイル分割後） |
| × | Phase S 完了前の Phase 1 本実装 |
| × | `CoreAudioService` 未着手での Phase 3 |

---

## 1 フェーズあたりの推奨コミット粒度

1. `AGENTS.md` — フェーズ開始（進捗ログ）
2. 実装コミット（機能単位。例: Domain / Service / UI）
3. `implementation-plan-v01.md` — 完了タスクを `- [x]`
4. `AGENTS.md` — フェーズ完了 + レビュー結果サマリ
5. （Phase S）`docs/adr/` またはスパイク記録表の更新

---

## クイック参照: 今どのフェーズか

| 状態 | 次のアクション |
|------|----------------|
| リポジトリはドキュメントのみ | Phase 0 から |
| Xcode プロジェクトなし | Phase 0.2 |
| スパイク未実施 | Phase S（Phase 1 禁止） |
| メニューのみ・Core Audio なし | Phase 2 |
| 一覧のみ・切替なし | Phase 3 |
| UT 未作成 | Phase 5 |
| UT 緑・手動 QA 残 | Phase 6 |

現在のフェーズは [AGENTS.md](../AGENTS.md) の進捗ログを参照。
