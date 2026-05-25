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

**Menu Bar Label**（メニューバーラベル）:
Menu Bar Icon の横に、現在の Default Input Device の Display Name を常時表示する v0.2 機能。ユーザー設定で ON/OFF でき、デフォルトはオフ。OFF のときは v0.1 どおりアイコンのみ（Menu Bar Tooltip は残す）。長い Display Name はメニューバー幅のため切り詰めて表示し、全文は Menu Bar Tooltip で示す。`currentDevice` が無いときはラベル文字を出さずアイコンのみとする。
_Avoid_: ステータス表示, トレイラベル（Menu Bar Icon と混同しやすい）

**Menu Bar Tooltip**（メニューバーツールチップ）:
Menu Bar Icon にホバーしたときだけ、現在の Default Input Device の Display Name を表示する補助表示。
_Avoid_: ヘルプ, ヒント（設定画面のヘルプと混同しやすい）

**Background App**（バックグラウンドアプリ）:
Dock や ⌘+Tab に出さず、Menu Bar Icon とメニューだけで操作する常駐形態。終了はメニュー内の「終了」から行う。
_Avoid_: エージェントアプリ（実装用語としての Agent と混同しやすい）

**Manual Refresh**（手動再読み込み）:
ユーザーがメニュー内の「入力デバイスを再読み込み」を選び、一覧を再取得する操作。
_Avoid_: リフレッシュ, 更新（自動更新と区別がつかない）

**MicBar Settings**（MicBar 設定）:
v0.2 でメニュー内に置くユーザー設定。別の設定ウィンドウは作らない。項目は Login Item と Menu Bar Label の2トグル（いずれもデフォルトオフ）。
_Avoid_: 設定画面, Preferences（macOS のシステム設定と混同しやすい）

**Device List Refresh**（一覧更新）:
Core Audio から入力デバイス一覧と現在の Default Input Device を再取得し、メニュー表示を更新する処理。
_Avoid_: 同期, ポーリング

**Device List Loading**（一覧取得中）:
Device List Refresh の実行中状態。v0.1 ではメニューに「入力デバイスを取得中…」のみを表示し、前回の一覧は出さない。
_Avoid_: ローディング, スピナー（macOS メニューでは使わない）

## Flagged ambiguities

（未解決の用語・境界はここに追記する）

**Resolved (v0.2 スコープ)**: 次リリースの主目的は BOSS 自分用の「毎日の入力切替」体験の完成。必須機能は (1) ログイン時起動 (2) デバイス変更の自動監視 (3) Menu Bar 常時ラベル（ON/OFF 設定）。配布パッケージ・グローバルショートカット・macOS 通知は v0.2 に含めない。

**Resolved (v0.2 以降)**: 署名・DMG 配布は **v1.0**。グローバルショートカット・macOS 通知は製品方針（ショートカットを増やさない・軽量）と矛盾するため当面見送り。近いバージョンでの再検討優先度は低い。

**Resolved (v0.2)**: Switch Error の UI 改善（失敗理由の区別・表示強化）は v0.2 に含めない。v0.1 のメニュー内定型文のままとする。

**Resolved (v0.2)**: Device Change Monitoring と Background / Foreground Refresh の設計理由は **ADR-0003**（`docs/adr/0003-device-change-monitoring-and-refresh-modes.md`）に記録する。

**Resolved (v0.2)**: v0.2 の要件正本は `requirements-v02.md`。`requirements-v01.md` は v0.1 完了時点の正本として維持し、ロードマップのみ v0.2 確定内容に合わせて更新する。

**Resolved (v0.2)**: **Login Item**（ログイン項目）— Mac ログイン時に MicBar を自動起動するかの設定。デフォルトはオフ。ユーザーがメニュー内で明示的にオンにしたときだけ `SMAppService` で登録する。macOS のログイン項目設定で外された場合も、起動時およびメニュー表示時に `SMAppService` の実状態とトグル表示を同期する。

**Resolved (v0.2)**: **Device Change Monitoring**（デバイス変更監視）— Core Audio のプロパティ変更通知で Device List Refresh を起動する。監視対象は (1) 入力デバイス一覧の変化 (2) Default Input Device の変化（システム設定など MicBar 外での変更を含む）。メニューが閉じているときは **Background Refresh**（バックグラウンド更新）として `loading` にせず Store と Menu Bar 表示だけ更新する。メニューが開いているときは v0.1 どおり Device List Loading を表示する **Foreground Refresh**（前景更新）。直近の Background Refresh 以降に変更がなければ、メニュー表示時の Refresh は Loading なしで即一覧とする。Manual Refresh は常に Foreground Refresh。

**Resolved**: UI 文言は「入力マイク」ではなく「入力デバイス」を使う。一覧には Virtual Input Device も含める。

**Resolved (v0.1)**: Device List Refresh は (1) アプリ起動時 (2) メニュー表示時 (3) Manual Refresh 時 (4) 切り替え成功時に行う。常時ポーリングと Core Audio 変更通知は v0.2 以降。

**Resolved (v0.1)**: 同名 Input Device がある場合、Display Name に連番 suffix を付ける（`USB Audio 2`）。transport 等の詳細 suffix は v1.0 以降。

**Resolved (v0.1)**: 切替失敗時は Switch Error をメニュー内に表示する。UserNotifications は使わない。

**Resolved (v0.1)**: 切替成功時は Switch Success として無言。チェックマークと「現在の入力:」の更新のみ。

**Resolved (v0.1)**: Menu Bar Icon はアイコンのみ。現在デバイスは Menu Bar Tooltip（ホバー時）とメニュー内「現在の入力:」で示す。

**Resolved (v0.2)**: Menu Bar Label はデフォルトオフ。オン時のみ Display Name を Menu Bar Icon 横に常時表示する。

**Resolved (v0.2)**: MicBar Settings はメニュー内フッターにトグル2つのみ。Login Item・Menu Bar Label・Manual Refresh・終了の順を想定。

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
