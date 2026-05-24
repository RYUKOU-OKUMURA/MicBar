# MicBar v0.1 実装計画

> **要件**: [requirements-v01.md](./requirements-v01.md)  
> **用語**: [CONTEXT.md](./CONTEXT.md)  
> **ADR**: [docs/adr/](./docs/adr/)  
> **エージェント運用**: [AGENTS.md](./AGENTS.md) · [docs/agent-implementation-plan.md](./docs/agent-implementation-plan.md)

進捗はチェックボックスを `- [x]` に更新して管理する。フェーズ完了時は **完了条件** をすべて満たしてから次へ進む。

### エージェント向け（必須）

1. タスク完了ごとに本ファイルの該当チェックを `- [x]` に更新する。  
2. フェーズ実装後は [AGENTS.md](./AGENTS.md) の手順どおり **サブエージェントでレビュー** する。  
3. [AGENTS.md](./AGENTS.md) の進捗ログを更新し、**こまめに git commit** する。  
4. フェーズ別のサブエージェント割当は [docs/agent-implementation-plan.md](./docs/agent-implementation-plan.md) に従う。

---

## 全体マイルストーン

| フェーズ | 内容 | 完了条件の要約 |
|---------|------|----------------|
| **0** | リポジトリ・Xcode 準備 | 空の MenuBarExtra がビルド・起動できる |
| **S** | 事前検証（スパイク） | 権限方針確定・BOSS 環境で切替成立を確認 |
| **1** | メニューシェル | AC-001, AC-007 |
| **2** | Core Audio 一覧 | AC-002, AC-003, AC-008（一覧・現在・Tooltip） |
| **3** | 切り替え | AC-004, AC-005 |
| **4** | 状態・エラー・仕上げ | AC-006, 全 UI 状態 |
| **5** | ユニットテスト | ロジック層の UT 緑 |
| **6** | 手動 QA・v0.1 完了 | 全 AC クリア |

```text
0 → S → 1 → 2 → 3 → 4 → 5 → 6
         ↑ ADR-0002（Phase 1 の前に必須）
```

---

## フェーズ 0: プロジェクト準備

### 0.1 開発環境

- [x] Xcode がインストールされ、コマンドラインツールが有効
- [x] 対象 Mac が macOS 13+ / Apple Silicon であることを確認
- [x] BOSS 実機にテスト用デバイス（USB Audio, AirPods 等）が接続可能

### 0.2 Xcode プロジェクト作成

- [x] `MicBar` macOS App プロジェクトを作成（SwiftUI App）
- [x] Deployment Target: **macOS 13.0**
- [x] Architectures: **arm64** のみ（Intel 無効）
- [x] Bundle Identifier を決定（例: `com.boss.MicBar`）
- [x] App Category: Utility

### 0.3 Background App 設定

- [x] **Application is agent (UIElement)** = YES（Dock 非表示）
- [x] メニューバー専用であることを Info.plist / Target 設定で確認
- [x] 起動後、Dock にアイコンが出ないことを確認

### 0.4 ディレクトリ構成（目標）

```text
MicBar/
├── MicBarApp.swift
├── UI/
│   ├── MenuBarView.swift
│   └── DeviceMenuItemView.swift
├── State/
│   └── AudioDeviceStore.swift
├── Domain/
│   ├── AudioInputDevice.swift
│   ├── DisplayNameFormatter.swift
│   └── AudioDeviceError.swift
├── Infrastructure/
│   └── CoreAudioService.swift
└── Tests/
    ├── DisplayNameFormatterTests.swift
    └── AudioDeviceStoreTests.swift
```

- [x] 上記フォルダ／ファイルの空骨格を作成
- [x] `Core Audio` framework をリンク

### 0.5 完了条件（フェーズ 0）

- [x] `⌘R` でビルド成功
- [x] クラッシュせず起動（まだメニュー内容はダミーでよい）

---

## フェーズ S: 事前検証（ADR-0002）

> Phase 1 の前に完了させる。結果は `docs/adr/` または本ファイル末尾の **スパイク記録** に残す。

### S.1 マイク権限スパイク

- [x] Core Audio のみ呼ぶ最小コマンドライン or ミニアプリを作成
- [x] `listInputDevices` 相当: 入力デバイス一覧取得
- [x] `getDefaultInputDevice` 相当: 現在の Default Input Device 取得
- [x] `setDefaultInputDevice` 相当: 別デバイスへ切替
- [x] 各操作時に **マイク権限ダイアログが出ないか** 記録
- [x] 出た場合: どの API で出たか、回避策の有無を調査
- [x] 結論を 1 行で文書化（例: 「権限不要で進行可」/ 「Entitlement 要」）

### S.2 CLI 比較検証（任意・推奨）

- [ ] `switchaudio-osx` をインストール（Homebrew）
- [ ] `SwitchAudioSource -a -t input` で一覧取得
- [ ] BOSS 環境の全 Input Device 名をメモ（requirements-v01 §12 と照合）
- [ ] `-s "{デバイス名}"` で 2 台以上切替成功を確認
- [ ] システム設定の「入力」表示と一致するか確認

### S.3 スパイク記録

- [x] 権限スパイク結果
- [x] CLI 比較結果（実施した場合）
- [x] Phase 1 へ進行 GO / NO-GO を決定

### 完了条件（フェーズ S）

- [x] マイク権限方針が確定し、requirements-v01 NF-006 と矛盾しない
- [x] BOSS 環境で「切替自体は可能」と確認済み

---

## フェーズ 1: メニューシェル

**対応要件**: F-001, F-002（骨格）, F-010  
**受け入れ**: AC-001, AC-007

### 1.1 MenuBarExtra 骨格

- [x] `MicBarApp` に `MenuBarExtra("MicBar", systemImage: "mic")` を定義
- [x] `.menuBarExtraStyle(.menu)` を設定
- [x] Menu Bar Icon が表示される

### 1.2 固定メニュー（ダミー）

- [x] ヘッダー `MicBar`（Disabled ラベル）
- [x] 区切り線
- [x] 「入力デバイスを再読み込み」（まだ空動作で可）
- [x] 「終了」→ `NSApplication.shared.terminate(nil)`

### 1.3 終了・常駐確認

- [x] 「終了」でアプリが終了する
- [x] 再起動で Menu Bar Icon が復帰する
- [x] Dock / ⌘+Tab に出ない（Background App）

### 完了条件（フェーズ 1）

- [x] AC-001: 起動後アイコン表示
- [x] AC-007: メニューから終了可能

---

## フェーズ 2: Core Audio 一覧取得

**対応要件**: F-003, F-004, F-006（一部）, Device List Loading  
**受け入れ**: AC-002, AC-003, AC-008

### 2.1 Domain モデル

- [x] `AudioInputDevice` を定義（`id`, `uid`, `name`, `displayName`, `isDefault`）
- [x] `AudioDeviceError` を定義（取得失敗、切替失敗、デバイスなし等）
- [x] `DisplayNameFormatter` を実装（同名 → `USB Audio 2` 連番 suffix）

### 2.2 CoreAudioService（読み取り）

- [x] `listInputDevices() -> [AudioInputDevice]`
  - [x] `kAudioHardwarePropertyDevices` で全デバイス取得
  - [x] `kAudioDevicePropertyStreamConfiguration` で入力チャンネルありのみフィルタ
  - [x] `kAudioObjectPropertyName` で名前取得
  - [x] `kAudioDevicePropertyDeviceUID` で UID 取得
- [x] `getDefaultInputDevice() -> AudioInputDevice?`
  - [x] `kAudioHardwarePropertyDefaultInputDevice` を取得
- [x] Core Audio エラーを `AudioDeviceError` にマッピング

### 2.3 AudioDeviceStore（読み取り・状態）

- [x] `ObservableObject` + `@Published` で状態管理
- [x] 状態: `devices`, `currentDevice`, `isLoading`, `errorMessage`, `listState`（通常/なし/失敗）
- [x] `refresh()` を実装（非同期でも可、UI スレッド更新に注意）
- [x] 起動時に `refresh()` を呼ぶ

### 2.4 Device List Loading UI

- [x] `isLoading == true` のときメニューは「入力デバイスを取得中…」のみ
- [x] 取得完了後に通常メニューへ切替
- [x] メニュー**表示時**に `refresh()` を呼ぶ（`onAppear` 等）

### 2.5 メニュー UI（一覧・現在）

- [x] `現在の入力: {displayName}` をヘッダー下に表示
- [x] 各 Input Device を `Button` / `Picker` で一覧表示
- [x] 現在の Default Input Device にチェックマーク（`✓` または `systemImage: checkmark`）
- [x] デバイスなし → §9.2 の文言
- [x] 取得失敗 → §9.3 の文言

### 2.6 Menu Bar Tooltip

- [x] 現在の `displayName` を Tooltip に設定（`MenuBarExtra` の tooltip または `.help()`）
- [x] デバイス未取得時は空 or 「MicBar」などフォールバック

### 2.7 Manual Refresh（一覧のみ）

- [x] 「入力デバイスを再読み込み」クリックで `refresh()` 実行

### 完了条件（フェーズ 2）

- [x] AC-002: メニューで一覧表示（Loading → 一覧）
- [x] AC-003: 現在デバイスにチェック
- [x] AC-008: Tooltip に現在の Display Name
- [x] システム設定の「入力」と MicBar の Default が一致

---

## フェーズ 3: 切り替え

**対応要件**: F-005, F-006, Device List Refresh（切替後）  
**受け入れ**: AC-004, AC-005

### 3.1 CoreAudioService（書き込み）

- [x] `setDefaultInputDevice(deviceID:)` を実装
  - [x] `AudioObjectSetPropertyData` + `kAudioHardwarePropertyDefaultInputDevice`
- [x] 失敗時に `AudioDeviceError.switchFailed` 等を返す

### 3.2 AudioDeviceStore（切替）

- [x] `switchDevice(_ device: AudioInputDevice)` を実装
- [x] 成功時: Switch Success（無言）→ `refresh()`
- [x] 失敗時: `errorMessage` に Switch Error 定型文をセット

### 3.3 メニュー UI（切替アクション）

- [x] デバイス行タップで `switchDevice` を呼ぶ
- [x] 切替後、チェックマークと「現在の入力:」が更新される
- [x] Switch Error をメニュー上部などに表示（§9.4）

### 3.4 Manual Refresh（切替含む全体）

- [x] 再読み込み後もチェック・現在表示が正しい

### 完了条件（フェーズ 3）

- [x] AC-004: クリックで Default Input Device が変わる（システム設定で確認）
- [x] AC-005: Manual Refresh で一覧・チェックが更新される
- [x] 切替成功時にトースト・通知が出ない（Switch Success）

---

## フェーズ 4: エラー耐性・仕上げ

**対応要件**: F-008, NF-004, 全 UI 状態  
**受け入れ**: AC-006

### 4.1 エッジケース処理

- [x] 一覧に残った切断済みデバイスを選んでもクラッシュしない → Switch Error
- [x] 無効な `AudioDeviceID` で Core Audio が失敗してもクラッシュしない
- [x] `refresh()` 失敗時に取得失敗状態へ遷移
- [x] 切替失敗後もメニュー操作可能（再試行・Manual Refresh）

### 4.2 競合・再入

- [x] Loading 中に二重 `refresh()` しても状態が壊れない（キャンセル or 直列化）
- [x] 切替中に `refresh()` が走っても整合性が保たれる

### 4.3 UI 文言・表示の最終確認

- [x] ユーザー向け文言は「入力デバイス」（「マイク」は使わない）
- [x] Switch Error 定型文が requirements-v01 と一致
- [x] v0.1 メニューに「ログイン時に起動」行が**ない**

### 4.4 コード品質（軽量）

- [x] Core Audio 呼び出しを `CoreAudioService` に集約（UI から直接呼ばない）
- [x] 不要な `print` / デバッグコードを削除
- [x] メモリリーク・リスナー未解除がない（v0.1 はリスナー未使用のはず）

### 完了条件（フェーズ 4）

- [x] AC-006: 切断済みデバイス選択でクラッシュしない
- [x] §9.1〜9.4 の全 UI 状態を手動で一度ずつ確認

---

## フェーズ 5: ユニットテスト

**対応**: requirements-v01 §12（自動テスト）

### 5.1 DisplayNameFormatterTests

- [x] 名前がすべて異なる → そのまま返す
- [x] 同名 2 件 → `Name`, `Name 2`
- [x] 同名 3 件 → `Name`, `Name 2`, `Name 3`
- [x] 空配列 → 空配列

### 5.2 AudioDeviceStoreTests（モック Core Audio）

- [x] `CoreAudioService` のプロトコル化 or モック注入
- [x] `refresh` 成功 → `devices` 更新、`isLoading` false
- [x] `refresh` 失敗 → `listState` 取得失敗
- [x] デバイス 0 件 → `listState` デバイスなし
- [x] `isDefault` のデバイスにチェック判定ロジックが正しい
- [x] `switchDevice` 失敗 → `errorMessage` に Switch Error 文言

### 5.3 CI（任意・v0.1）

- [x] ローカルで `⌘U` 全テスト緑
- [ ] （任意）GitHub Actions で macOS ランナー + `xcodebuild test`

### 完了条件（フェーズ 5）

> **UT スコープ**: UI / 実機 Core Audio は UT 対象外（requirements-v01 §12）。

- [x] 上記 UT がすべてパス
- [x] UI / 実機 Core Audio は UT の対象外であることを README or 本計画に明記済み（README.md 参照）

---

## フェーズ 6: 手動 QA・v0.1 完了判定

### 6.1 デバイス操作

- [x] USB マイク接続 → メニュー再表示で一覧に出る
- [x] USB マイク取り外し → 再表示 or Manual Refresh で反映
- [x] AirPods 接続 → 一覧に出る・切替できる
- [x] AirPods 切断 → エラーまたは一覧から消える（クラッシュなし）
- [x] Display Audio（ディスプレイ内蔵）が一覧に出る
- [x] Speaker Audio Recorder（仮想）が一覧に出る

### 6.2 操作フロー

- [x] NF-001: アイコン → デバイス選択の 2 操作で切替完了
- [x] メニュー再オープンで Device List Refresh が走る
- [x] Tooltip が現在デバイスと一致

### 6.3 外部アプリ（参考）

- [x] システムデフォルト追従のアプリで入力が変わる
- [x] Per-App Input Setting 固定のアプリでは変わらない（仕様どおり）

### 6.4 受け入れ条件チェックリスト

- [x] AC-001
- [x] AC-002
- [x] AC-003
- [x] AC-004
- [x] AC-005
- [x] AC-006
- [x] AC-007
- [x] AC-008

### 6.5 v0.1 完了

- [x] `requirements-v01.md` のスコープ外機能が入っていないことを確認
- [ ] Applications にコピーして日常利用 1 日分の試用（任意）
- [x] 既知の問題・v0.2 送り事項を **既知の問題** に記録（下記）

### 完了条件（フェーズ 6）

- [x] 上記 AC すべてクリア
- [x] BOSS が「v0.1 として使える」と判断

---

## スパイク記録（フェーズ S 完了後に記入）

### マイク権限

| 項目 | 結果 |
|------|------|
| 一覧取得時 | ダイアログなし（MicBarSpike list, 2026-05-24） |
| 現在取得時 | ダイアログなし（MicBarSpike default） |
| 切替時 | ダイアログなし（Speaker Audio Recorder ↔ 内蔵マイク） |
| 結論 | **権限不要で進行可**（NF-006 適合） |

### CLI 比較（実施時）

| 項目 | 結果 |
|------|------|
| 一覧一致 | 未実施（switchaudio-osx 未インストール） |
| 切替成功デバイス | Core Audio スパイク + BOSS 実機 UI で切替成功 |
| 結論 | CLI 比較は省略可。Core Audio ネイティブで GO |

---

## 既知の問題・v0.2 送り（随時追記）

| 内容 | 備考 |
|------|------|
| デバイス自動監視なし | メニュー表示時 Refresh で代替 |
| ログイン時起動なし | |
| Menu Bar 常時ラベルなし | Tooltip のみ |
| Intel Mac 非対応 | arm64 のみ |

---

## クイック参照: 要件 ID → フェーズ

| 要件 | フェーズ |
|------|---------|
| F-001 Background App | 0, 1 |
| F-002 メニュー | 1, 2, 3 |
| F-003 一覧 | 2 |
| F-004 現在表示・Tooltip | 2 |
| F-005 切替 | 3 |
| F-006 Manual Refresh | 2, 3 |
| F-008 Switch Error | 3, 4 |
| F-010 終了 | 1 |