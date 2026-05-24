# MicBar

macOS のメニューバーから、システムのデフォルト入力デバイスを切り替えるための常駐ユーティリティ。

## Language

**MicBar**:
macOS メニューバーに常駐し、入力デバイスの一覧表示と切り替えだけを担うアプリ。
_Avoid_: マイク切替アプリ, オーディオユーティリティ（範囲が広すぎる）

**Default Input Device**（デフォルト入力デバイス）:
macOS が「入力」として使う既定のオーディオデバイス。MicBar が変更する唯一のシステム設定。
_Avoid_: システムマイク, 入力マイク（物理マイクと混同しやすい）

**Per-App Input Setting**（アプリ別入力設定）:
Zoom、OBS など各アプリが内部で持つマイク選択。Default Input Device とは独立しており、MicBar の範囲外。
_Avoid_: アプリ内マイク, 個別マイク設定

**Input Device**（入力デバイス）:
Core Audio 上で入力チャンネルを持ち、デフォルト入力デバイスに設定可能なオーディオデバイス。物理マイク、Bluetooth、ディスプレイ内蔵、仮想デバイスを含む。
_Avoid_: 入力マイク（物理マイクだけを指すように聞こえる）

**Virtual Input Device**（仮想入力デバイス）:
物理マイクではなく、ループバック・録音パイプライン等のために Core Audio 上で入力チャンネルを持つデバイス（例: Speaker Audio Recorder）。
_Avoid_: 仮想マイク

**Display Name**（表示名）:
メニュー一覧に出す、ユーザー向けのデバイスラベル。macOS が返す名前を基本とし、同名が複数ある場合は連番 suffix を付けて区別する（例: `USB Audio`, `USB Audio 2`）。
_Avoid_: デバイス名（Core Audio の生の名前と混同しやすい）

**Switch Error**（切替エラー）:
Default Input Device への切り替えが失敗したとき、メニュー内に表示する短いユーザー向けメッセージ。v0.1 の定型文は「この入力デバイスに切り替えられませんでした。接続状態を確認してください。」macOS 通知は使わない。
_Avoid_: エラー通知, アラート（v0.1 ではダイアログも使わない）

**Switch Success**（切替成功）:
Default Input Device の切り替えが成功した状態。v0.1 では専用メッセージや通知は出さず、チェックマークと「現在の入力:」の更新だけで伝える。
_Avoid_: 成功通知, トースト

**Menu Bar Icon**（メニューバーアイコン）:
メニューバー常駐の表示。v0.1 ではマイクを連想できるアイコンのみとし、ラベル文字列は出さない。
_Avoid_: ステータス表示, トレイラベル

**Menu Bar Tooltip**（メニューバーツールチップ）:
Menu Bar Icon にホバーしたときだけ、現在の Default Input Device の Display Name を表示する補助表示。
_Avoid_: ヘルプ, ヒント（設定画面のヘルプと混同しやすい）

**Background App**（バックグラウンドアプリ）:
Dock や ⌘+Tab に出さず、Menu Bar Icon とメニューだけで操作する常駐形態。終了はメニュー内の「終了」から行う。
_Avoid_: エージェントアプリ（実装用語としての Agent と混同しやすい）

**Manual Refresh**（手動再読み込み）:
ユーザーがメニュー内の「入力デバイスを再読み込み」を選び、一覧を再取得する操作。
_Avoid_: リフレッシュ, 更新（自動更新と区別がつかない）

**Device List Refresh**（一覧更新）:
Core Audio から入力デバイス一覧と現在の Default Input Device を再取得し、メニュー表示を更新する処理。
_Avoid_: 同期, ポーリング

**Device List Loading**（一覧取得中）:
Device List Refresh の実行中状態。v0.1 ではメニューに「入力デバイスを取得中…」のみを表示し、前回の一覧は出さない。
_Avoid_: ローディング, スピナー（macOS メニューでは使わない）

## Flagged ambiguities

（未解決の用語・境界はここに追記する）

**Resolved**: UI 文言は「入力マイク」ではなく「入力デバイス」を使う。一覧には Virtual Input Device も含める。

**Resolved (v0.1)**: Device List Refresh は (1) アプリ起動時 (2) メニュー表示時 (3) Manual Refresh 時 (4) 切り替え成功時に行う。常時ポーリングと Core Audio 変更通知は v0.2 以降。

**Resolved (v0.1)**: 同名 Input Device がある場合、Display Name に連番 suffix を付ける（`USB Audio 2`）。transport 等の詳細 suffix は v1.0 以降。

**Resolved (v0.1)**: 切替失敗時は Switch Error をメニュー内に表示する。UserNotifications は使わない。

**Resolved (v0.1)**: 切替成功時は Switch Success として無言。チェックマークと「現在の入力:」の更新のみ。

**Resolved (v0.1)**: Menu Bar Icon はアイコンのみ。現在デバイスは Menu Bar Tooltip（ホバー時）とメニュー内「現在の入力:」で示す。Display Name の常時ラベル表示は v0.2 以降。

**Resolved (v0.1)**: MicBar は Background App として動作する。Dock 非表示、終了はメニュー内のみ。

**Resolved (v0.1)**: Device List Loading 中は「入力デバイスを取得中…」のみ表示。Stale list（前回一覧の仮表示）は使わない。

**Resolved (v0.1)**: Per-App Input Setting の説明はアプリ内に出さない。Default Input Device と Per-App Input Setting の境界はドキュメント（CONTEXT 等）で定義する。

**Resolved (v0.1)**: 対象 OS は macOS 13 Ventura 以降。macOS 12 向け AppKit fallback は v0.1 では行わない。

**Resolved (v0.1)**: v0.1 の届け方は BOSS 自身の Xcode Build & Run のみ。Developer ID 署名・DMG 配布は v1.0 / 配布準備フェーズまで含めない。

**Resolved (v0.1)**: Switch Error の定型文は「入力デバイス」表記を使う（「マイク」は使わない）。

**Resolved (v0.1)**: 自動テストは UI / Core Audio を除くロジック層のみ（Display Name 連番、状態遷移、Store 等）。実機確認は手動テストで行う。

**Resolved (v0.1)**: ビルド対象は Apple Silicon（arm64）のみ。Intel / Universal Binary は配布準備以降。

**Resolved (v0.1)**: マイク権限は要求しない設計。本実装前に Core Audio だけの最小検証で、macOS が権限ダイアログを出すか先に確認する（順序は ADR-0002）。

**Resolved**: v0.1 の要件正本は `requirements-v01.md`。実装タスクは `implementation-plan-v01.md`。`初期ファイル.md` はドラフトアーカイブ。用語は `CONTEXT.md`、実装方針は `docs/adr/`。

## Example dialogue

**Dev**: Zoom で使うマイクを変えたいんですが、MicBar で切り替えれば Zoom も変わりますか？

**Domain expert**: MicBar が変えるのは Default Input Device だけ。Zoom がシステムデフォルトに従う設定なら反映される。Zoom 側に Per-App Input Setting があるなら、MicBar では変わらない。v0.1 の UI ではその注意書きは出さない。ドキュメントで境界を説明する。
