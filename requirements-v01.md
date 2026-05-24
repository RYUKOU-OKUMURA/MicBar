# MicBar 要件定義書（v0.1）

> **正本**: 本ファイルが v0.1 の要件の単一ソースです。  
> **用語**: [CONTEXT.md](./CONTEXT.md)  
> **実装方針**: [docs/adr/](./docs/adr/)  
> **アーカイブ**: [初期ファイル.md](./初期ファイル.md)（ドラフト。本ファイルと矛盾する場合は本ファイルを優先）

## 1. プロダクト概要

**MicBar** は、macOS のメニューバーから **Default Input Device**（デフォルト入力デバイス）を素早く切り替える **Background App**（バックグラウンドアプリ）である。

システム設定を開かず、Menu Bar Icon をクリックして **Input Device**（入力デバイス）を選ぶだけで切り替えられる。主目的は **ショートカットを増やさず、見て選ぶ** こと。

## 2. 開発目的

* ショートカットキーを増やさずに入力デバイスを切り替えたい
* 今どの入力デバイスが選ばれているかを視覚的に確認したい
* Web 会議・配信・録音の前に素早く入力元を変更したい
* 出力デバイスではなく、入力だけを扱いたい

## 3. v0.1 スコープ

### 3.1 含めるもの

| ID | 内容 |
|----|------|
| F-001 | Menu Bar Icon 常駐（Background App、Dock 非表示） |
| F-002 | メニュー表示（入力デバイス一覧） |
| F-003 | Input Device 一覧取得（入力チャンネルありはすべて） |
| F-004 | 現在の Default Input Device 表示（メニュー内・Menu Bar Tooltip） |
| F-005 | Default Input Device の切り替え |
| F-006 | Manual Refresh（入力デバイスを再読み込み） |
| F-008 | Switch Error（メニュー内） |
| F-010 | 終了 |

**Device List Refresh** のタイミング: アプリ起動時、メニュー表示時、Manual Refresh 時、切替成功時。

### 3.2 含めないもの（v0.2 以降）

* ログイン時起動（F-009）
* デバイス変更の自動監視（F-007 / Core Audio プロパティリスナー）
* グローバルショートカット（F-012）
* macOS 通知（F-011）
* Menu Bar Icon への Display Name 常時表示
* 出力切り替え、音量、ミュート、レベルメーター、録音、AI 等
* Per-App Input Setting の変更・説明 UI
* Developer ID 署名・DMG 配布・App Store 配布

## 4. ユーザーストーリー

### US-001: メニューバーから入力デバイスを切り替える

メニューバーのアイコンをクリックし、一覧から使いたい Input Device を選び、システム設定を開かずに Default Input Device を変更したい。

### US-002: 現在の入力デバイスを確認する

メニュー内の「現在の入力:」、チェックマーク、Menu Bar Tooltip で、いまの Default Input Device を確認したい。

### US-003: デバイスの抜き差しに対応する

USB や AirPods の接続が変わったあと、メニューを開き直すか Manual Refresh で一覧を更新し、古いデバイスを選んで失敗することを減らしたい。

### US-004: ショートカットを覚えずに操作する

新しいキーボードショートカットを覚えず、見たままクリックで操作したい。

## 5. 機能要件（v0.1）

### F-001: Menu Bar Icon 常駐

* Background App として動作する（Dock・⌘+Tab 非表示）
* Menu Bar Icon はマイクを連想できるアイコンのみ（ラベル文字列なし）
* 終了はメニュー内「終了」のみ

### F-002: メニュー表示

メニュー構成（v0.1）:

```text
MicBar

現在の入力:
USB Audio

────────────

✓ USB Audio
  DELL S2725DC
  AirPods Pro
  Display Audio
  Speaker Audio Recorder

────────────

入力デバイスを再読み込み
終了
```

※ v0.1 には「ログイン時に起動」行は含めない。

### F-003: Input Device 一覧

* Core Audio が入力チャンネルを持つデバイスをすべて表示する
* 物理マイク、Bluetooth、ディスプレイ内蔵、Virtual Input Device を含む
* 出力専用デバイスは表示しない
* 表示順は macOS が返す順序のまま

### F-004: 現在の Default Input Device 表示

* メニュー上部: `現在の入力: {Display Name}`
* 一覧内: 現在のデバイスにチェックマーク
* Menu Bar Tooltip: ホバー時に現在の Display Name

### F-005: 切り替え

* 一覧の Input Device をクリックすると Default Input Device を変更する
* **Switch Success**: 成功メッセージ・通知は出さない。チェックマークと「現在の入力:」の更新のみ
* 切替成功後に Device List Refresh を行う

### F-006: Manual Refresh

「入力デバイスを再読み込み」で Device List Refresh を実行する。

### F-008: Switch Error

切替失敗時、メニュー内に次の定型文を表示する（通知・ダイアログは使わない）:

```text
この入力デバイスに切り替えられませんでした。接続状態を確認してください。
```

想定原因: デバイス切断、無効 ID、macOS 拒否、Core Audio 失敗、現在デバイス取得失敗。

### F-010: 終了

メニューからアプリを終了できること。

## 6. Display Name（重複名）

* 基本は macOS が返す名前
* 同名 Input Device が複数ある場合、連番 suffix を付ける（`USB Audio`, `USB Audio 2`）
* 内部識別は UID 優先（切替処理では AudioDeviceID を使用）

## 7. Device List Loading

Device List Refresh の実行中は、メニューに **「入力デバイスを取得中…」** のみを表示する。前回一覧の仮表示（stale list）は行わない。

## 8. 非機能要件（v0.1）

| ID | 要件 |
|----|------|
| NF-001 | 主要操作はメニューアイコンクリック → デバイスクリックの 2 操作以内 |
| NF-002 | 常時ポーリングは行わない（v0.2 で Core Audio 通知を検討） |
| NF-003 | 一覧取得中も Device List Loading 表示で待ちを明示する |
| NF-004 | 抜き差し・切断デバイス選択でクラッシュしない |
| NF-005 | 録音しない・入力ストリームを開かない・データ送信しない |
| NF-006 | マイク権限は要求しない設計。本実装前に最小検証でダイアログ有無を確認（[ADR-0002](./docs/adr/0002-spikes-before-phase-1.md)） |
| NF-007 | macOS 13 Ventura 以降、Apple Silicon（arm64）のみ |
| NF-008 | 届け方は BOSS 自身の Xcode Build & Run のみ |

## 9. UI 状態

### 9.1 通常

一覧 + 現在の Default Input Device にチェック。

### 9.2 デバイスなし

```text
入力デバイスが見つかりません
────────────
入力デバイスを再読み込み
終了
```

### 9.3 取得失敗

```text
入力デバイスを取得できませんでした
────────────
入力デバイスを再読み込み
終了
```

### 9.4 切替失敗

Switch Error の定型文をメニュー内に表示。

## 10. 制約

* MicBar が変更するのは **Default Input Device** のみ
* **Per-App Input Setting**（Zoom / OBS 等の個別マイク指定）は変更しない
* v0.1 の UI では Per-App Input Setting に関する注意書きは出さない（[CONTEXT.md](./CONTEXT.md) で境界を定義）

## 11. 受け入れ条件（v0.1）

| ID | 条件 |
|----|------|
| AC-001 | 起動後、Menu Bar Icon が表示される |
| AC-002 | メニューを開くと Input Device 一覧が表示される（取得中は Loading 表示） |
| AC-003 | 現在の Default Input Device にチェックが付く |
| AC-004 | 任意の Input Device をクリックすると Default Input Device が変わる |
| AC-005 | Manual Refresh で一覧が更新される |
| AC-006 | 切断済みデバイスを選んでもクラッシュしない |
| AC-007 | メニューから終了できる |
| AC-008 | Menu Bar Tooltip に現在の Display Name が出る |

## 12. テスト（v0.1）

### 自動（XCTest）

UI / Core Audio を除くロジック層:

* Display Name の連番 suffix
* 状態遷移（Loading / 通常 / エラー）
* Store のチェック判定・エラー状態

### 手動（BOSS 実機・必須）

* USB マイク抜き差し
* AirPods 接続・切断
* ディスプレイ内蔵・Virtual Input Device の表示
* Zoom / Meet / OBS での反映確認（Per-App Input Setting の有無を意識）

優先環境: Mac mini（Apple Silicon）、USB Audio、DELL S2725DC、AirPods Pro、Speaker Audio Recorder、Display Audio。

## 13. 開発順序（v0.1）

**タスク分解・進捗管理**: [implementation-plan-v01.md](./implementation-plan-v01.md)

[ADR-0002](./docs/adr/0002-spikes-before-phase-1.md) に従う:

1. **事前検証**: マイク権限ダイアログの有無（Core Audio 最小アプリ）、必要なら `switchaudio-osx` で切替成立確認（[ADR-0001](./docs/adr/0001-core-audio-native-for-v01.md)）
2. **Phase 1**: MenuBarExtra シェル、終了
3. **Phase 2〜3**: Core Audio 本実装（一覧・切替）
4. **Phase 4（v0.1 範囲）**: エラー耐性、手動テストでの安定化（自動監視は v0.2）

技術詳細は [初期ファイル.md](./初期ファイル.md) の `tech-stack.md` セクションを参照（実装時に `tech-stack-v01.md` へ分割してもよい）。

## 14. 後続バージョン（参考）

| バージョン | 主な追加 |
|-----------|---------|
| v0.2 | ログイン時起動、デバイス自動監視、Menu Bar 常時ラベル設定、エラー UI 改善 |
| v1.0 | transport 付き Display Name、スリープ復帰、配布パッケージ、Intel / Universal Binary |
